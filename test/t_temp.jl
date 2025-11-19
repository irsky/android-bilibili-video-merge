path = "/Users/npc/Documents/code/android-bilibili-video-merge/bilibili的视频缓存文件/1606328203/c_1619898984/16/"

BILI_DIR = "bilibili的视频缓存文件"

r1 = r".*/$(Regex.escape(BILI_DIR))/\d+/c_\d+/\d+/"
r2 = Regex(".*/$BILI_DIR/\\d+/c_\\d+/\\d+/")
r3 = r".*/" * Regex.escape(BILI_DIR) * "/\\d+/c_\\d+/\\d+/"

match(r2, path)


