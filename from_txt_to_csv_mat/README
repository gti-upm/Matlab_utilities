Se incluyen los siguientes tres ficheros para poder convertir un fichero ".xml" con información del ground truth de una secuencia etiquetada con Viper para convertirlos en ficheros ".csv" y ficheros ".mat" con la información del ground truth correspondiente.
* transformacion_csv: script que convierte el fichero ".xml" en un fichero ".csv".
  * Esta función tiene los siguientes parámetros de entrada:
    * xml_name: nombre del fichero xml que se desea procesar.
    * groundtruth_directory: nombre de la carpeta dónde se encuentra el fichero xml.
    * training_frame_interval: tupla de números que identifican el primer y último frame que se utilizarán para entrenar.
    * tes_frame_interval: tupla de números que identifican el primer y último frame que se utilizarán para test.
  * Por ejemplo, si tenemos una secuencia de 100 frames de la que queremos utilizar los 80 primeros para entrenar y los 20 últimos para test, el fichero de groundtruth se llama "test_1.xml" y se encuentra en la carpeta "D:/u/tmv/prueba_1", se ejecutaría la siguiente función:
    * transformacion_csv("test_1.xml","D:/u/tmv/prueba_1",[1,80],[81,100])
  * Al ejecutar dicha función, se generarán diversos ficheros ".csv" en el directorio que se le pase como entrada en groundtruth_directory:
    * Se generará un fichero "_training_detection.csv" en dónde se guardará el ground truth de las detecciones de todas las clases correspondientes a los frames de entrenamiento. 
    * Se generará un fichero "_test_detection.csv" en dónde se guardará el ground truth de las detecciones de todas las clases correspondientes a los frames de test.
    * Se generará un fichero "_training_class_detection.csv" por cada clase de objeto, en dónde se guardará el ground truth de las detecciones de la clase correspondientes a los frames de entrenamiento. 
    * Se generará un fichero "_test_class_detection.csv" por cada clase de objeto, en dónde se guardará el ground truth de las detecciones de la clase correspondientes a los frames de test.
* GT_csv_GT_mat: script que convierte el fichero ".csv" generao anteriormente en un fichero ".mat".
  * Esta función tiene como entrada:
    * gt_filename: nombre del archivo ".csv" que se quiere convertir a ".mat".
    * img_dir: nombre de la carpeta dónde se encuentran las imágenes correspondientes al ficher ".csv".
  * Por ejemplo, si queremos convertir el fichero "gt_prueba_1.csv", y las imágenes se encuentran en el directorio "D:/u/tmv/prueba_1/", se ejecutaría la siguiente función:
    * GT_csv_GT_mat("gt_prueba_1.csv","D:/u/tmv/prueba_1/")
  * Al ejecutar dicha función, se generará el fichero "groundTruth_prueba_1.mat" que tendrá una estructura de matlab con los siguientes campos por cada imágen de la secuencia:
    * n_frame: número del frame dentro de la secuencia.
    * frame_name: nombre de la imágen.
    * type: tipo de objeto, es un vector que tendrá tantos elementos como bounding boxes tenga la imágen.
    * id: identificador del objeto.
    * bbox: bounding box que vendrá dada por 4 coordenadas: (x_ini,y_ini,largo,ancho). Será una matriz en la que cada fila representa un objeto.
* getFileSet: función auxiliar que te devuelve un listado de los ficheros que hay en el directorio que se le pasa como entrada.
  * Esta función tiene los siguientes parámetros de entrada:
    * path: directorio del cual se quiere extraer la lista de ficheros.
    * imgType: extensión de los ficheros de los cuales se quiere extraer el listado.
