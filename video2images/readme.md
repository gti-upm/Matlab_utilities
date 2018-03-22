# Readme

Se han implementadouna serie de funciones en Matlab para la conversión de vídeos a secuencias deimágenes.

- "video2images.m":     toma como argumentos de entrada un fichero de vídeo y la extensión de las     imágenes de salida, crea una carpeta con el mismo nombre que el vídeo y     extrae en esa carpeta cada frame del vídeo a un archivo imagen. El nombre     de los archivos son numéricos empezando por el cero.
- "videoSet2images.m     ":  realiza las mismas     operaciones que el script anterior pero para todos los vídeos que se     encuentren en el path especificado como entrada.
- "video2jpgMaxQua.m":     similar a "video2images.m" pero fijando la extensión de salida     a 'jpg' y configurando la máxima calidad posible para los archivos jpg     generados.
- "videoSet2jpgMaxQua.m":     similar a "videoSet2images.m" pero fijando la extensión de     salida a 'jpg' y configurando la máxima calidad posible para los archivos     jpg generados.