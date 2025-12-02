# Наши цели вообще

1. Загрузить несколько JPEG-картинок
2. Поиздеваться на AC/DC-коэфициентами
3. Посмотреть что получилось
4. Сохранить картинку обратно (без пересжатия)
5. Сделать гимп-подобный редактор с кучей кисточек и фильтров
6. Свой богатый UI-фреймверк
7. Свой window-менеджер для управления тайлинговыми окошками, списками, вкладочками и аккордеонами

# Что будем делать сегодня Sweetmorn, the 44th day of The Aftermath in the YOLD 3191

+Попробуем просто распаковать картинку (jpeg)
+Попробуем упростить либу
+Попробуем выковырять DCT-коэфициенты
Сконвертировать DCT-коэфициенты в картинку обратно



# Предложения нейросети

* boundary expand - аналог canvas size в gimp
* see after boundary image - расширить размер картинки до границы MCU, показать скрытые пиксели
* mirror/flipping rotation - повороты картинки на 90/180/270 градусов, переворот картинки по вертикали или горизонтали
* grayscale conversion - преобразование картинки в черно-белую (просто отбрасываем хроматические каналы)
* сhroma enhance - усиливаем цветность на манер старых телевизоров
* chroma lower - не сразу делаем картинку чернобелой, а слегка приглушаем цвета
* chroma blur - удаляем верхние частоты из хроматических каналов
* inversion - простой эффект инверсии
* ajust brightness - повысить яркость (добавить значение в dc[0])
* bluriness - удалить верхние частоты
* sharpening - ???
* denoise - ???
* deblock - https://ieeexplore.ieee.org/document/1197575, https://www.researchgate.net/publication/220808862_Adaptive_Deblocking_of_Images_with_DCT_Compression
* add grain - добавить шума???
* image fusion - склеить несколько картинок
* edge detection
* edge enhancement
* image resize - ресайз по фактору 2
* perceptual encryption - визуальное шифрование???
* band-pass
* foveau rendering, compression
* region blackout
* patch recompression like in fused images

# Ссылки

* https://github.com/richgel999/jpeg-compressor
* https://medium.com/@duhroach/reducing-jpg-file-size-e5b27df3257c
* https://en.wikipedia.org/wiki/Discrete_cosine_transform
* https://www.ee.columbia.edu/~jh2700/Detecting%20Doctored%20JPEG%20Images%20Via%20DCT%20Coefficient%20Analysis%20.pdf
