package br.com.machadodeassis.biblioteca.tts

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import androidx.core.app.NotificationCompat
import br.com.machadodeassis.biblioteca.MainActivity
import br.com.machadodeassis.biblioteca.R
import br.com.machadodeassis.biblioteca.db.MachadoDatabase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.util.Locale

class TtsPlaybackService : Service(), TextToSpeech.OnInitListener {
    companion object {
        const val ACTION_PLAY = "machado.tts.PLAY"
        const val ACTION_RESUME = "machado.tts.RESUME"
        const val ACTION_PAUSE = "machado.tts.PAUSE"
        const val ACTION_STOP = "machado.tts.STOP"
        const val EXTRA_CHAPTER_ID = "chapter_id"
        private const val CHANNEL = "machado_reading"
        private const val NOTIFICATION = 71
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var tts: TextToSpeech? = null
    private var paragraphs = emptyList<String>()
    private var index = 0
    private var ready = false
    private var pendingChapter: String? = null
    private var currentChapterId: String? = null
    private var currentWorkId: String? = null
    private var startedAt = 0L

    override fun onCreate() {
        super.onCreate()
        createChannel()
        tts = TextToSpeech(this, this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PLAY -> loadAndPlay(intent.getStringExtra(EXTRA_CHAPTER_ID))
            ACTION_RESUME -> speakCurrent()
            ACTION_PAUSE -> tts?.stop()
            ACTION_STOP -> { tts?.stop(); stopForeground(STOP_FOREGROUND_REMOVE); stopSelf() }
        }
        return START_NOT_STICKY
    }

    private fun loadAndPlay(chapterId: String?) {
        if (chapterId == null) return
        if (!ready) { pendingChapter = chapterId; return }
        scope.launch(Dispatchers.IO) {
            val dao = MachadoDatabase.get(this@TtsPlaybackService).dao()
            val chapter = dao.chapter(chapterId)
            val loaded = dao.paragraphs(chapterId)
            launch(Dispatchers.Main) {
                currentChapterId = chapterId
                currentWorkId = chapter?.workId
                paragraphs = loaded
                index = 0
                if (paragraphs.isNotEmpty()) speakCurrent()
            }
        }
    }

    private fun speakCurrent() {
        val text = paragraphs.getOrNull(index) ?: run { stopSelf(); return }
        startForeground(NOTIFICATION, notification("Ouvindo capítulo • ${index + 1}/${paragraphs.size}"))
        startedAt = android.os.SystemClock.elapsedRealtime()
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "paragraph_$index")
    }

    override fun onInit(status: Int) {
        if (status != TextToSpeech.SUCCESS) return
        val locale = Locale("pt", "BR")
        val offlineVoice = tts?.voices?.firstOrNull { it.locale.language == locale.language && !it.isNetworkConnectionRequired }
        if (offlineVoice == null) { stopSelf(); return }
        tts?.voice = offlineVoice
        ready = true
        pendingChapter?.let { pendingChapter = null; loadAndPlay(it) }
        tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) = Unit
            override fun onDone(utteranceId: String?) {
                val elapsed = android.os.SystemClock.elapsedRealtime() - startedAt
                val chapterId = currentChapterId
                val workId = currentWorkId
                if (chapterId != null && workId != null) scope.launch(Dispatchers.IO) { MachadoDatabase.get(this@TtsPlaybackService).dao().addActivity(chapterId, 0, elapsed, System.currentTimeMillis()) }
                index++
                if (index < paragraphs.size) speakCurrent()
            }
            override fun onError(utteranceId: String?) { stopSelf() }
        })
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        scope.coroutineContext.cancel()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        getSystemService(NotificationManager::class.java).createNotificationChannel(NotificationChannel(CHANNEL, "Leitura em voz", NotificationManager.IMPORTANCE_LOW))
    }

    private fun notification(text: String) = NotificationCompat.Builder(this, CHANNEL)
        .setSmallIcon(R.drawable.ic_machado)
        .setContentTitle("Machado de Assis")
        .setContentText(text)
        .setContentIntent(PendingIntent.getActivity(this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
        .addAction(0, "Pausar", servicePending(ACTION_PAUSE))
        .addAction(0, "Continuar", servicePending(ACTION_RESUME))
        .addAction(0, "Parar", servicePending(ACTION_STOP))
        .setOngoing(true)
        .build()

    private fun servicePending(action: String): PendingIntent = PendingIntent.getService(this, action.hashCode(), Intent(this, TtsPlaybackService::class.java).setAction(action), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
}
