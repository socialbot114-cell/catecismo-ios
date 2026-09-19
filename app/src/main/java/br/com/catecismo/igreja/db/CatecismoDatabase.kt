package br.com.catecismo.igreja.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase

@Database(
    entities = [WorkEntity::class, ChapterEntity::class, ParagraphEntity::class, ParagraphFts::class, ChapterProgressEntity::class],
    version = 2,
    exportSchema = false
)
abstract class CatecismoDatabase : RoomDatabase() {
    abstract fun dao(): LibraryDao

    companion object {
        @Volatile private var instance: CatecismoDatabase? = null
        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL("ALTER TABLE chapter_progress ADD COLUMN paragraphIndex INTEGER NOT NULL DEFAULT -1")
                db.execSQL("ALTER TABLE chapter_progress ADD COLUMN readingTimeMs INTEGER NOT NULL DEFAULT 0")
                db.execSQL("ALTER TABLE chapter_progress ADD COLUMN listeningTimeMs INTEGER NOT NULL DEFAULT 0")
                db.execSQL("ALTER TABLE chapter_progress ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0")
                db.execSQL("ALTER TABLE chapter_progress ADD COLUMN completedAt INTEGER")
                db.execSQL("UPDATE chapter_progress SET isCompleted = 1, completedAt = updatedAt WHERE progress >= 100")
            }
        }

        fun get(context: Context): CatecismoDatabase =
            instance ?: synchronized(this) {
                instance ?: Room.databaseBuilder(context.applicationContext, CatecismoDatabase::class.java, "catecismo.db")
                    .addMigrations(MIGRATION_1_2)
                    .build().also { instance = it }
            }
    }
}
