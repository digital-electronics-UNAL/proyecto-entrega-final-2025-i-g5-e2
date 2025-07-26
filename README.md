[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=19980177&assignment_repo_type=AssignmentRepo)
# Proyecto final - Electrónica Digital 1 - 2025-I

# Integrantes

[David Felipe Cardenas Cubides](https://github.com/dcardenascu)

[Alvaro Nicolas Lopez Brijaldo](https://github.com/Nicolasss16)

[Brayan Yesid Santos Gonzalez](https://github.com/BsantosG)

# Introduccion

El presente informe expone el desarrollo de nuestro proyecto SOMA, cuyo propósito es asistir a
personas con visión reducida mediante un sistema electrónico capaz de detectar obstáculos
cercanos y emitir alertas sensoriales. En muchos casos, los bastones tradicionales no detectan
objetos ubicados por encima del nivel de la cintura o suspendidos en el entorno, lo que representa
un riesgo importante de colisiones y accidentes. La motivación principal detrás de este proyecto es
mejorar la autonomía y seguridad de estas personas, integrando tecnología accesible y confiable.

La solución planteada fue desarrollar un sistema que integre un sensor ultrasónico HC-SR04, un
FPGA para el procesamiento de señales y la toma de decisiones, y dispositivos de salida que
incluya un buzzer piezoeléctrico y un motor de vibración o rumble. El sistema está diseñado para
detectar la proximidad de un obstáculo y emitir una alerta sonora o háptica proporcional a la
distancia medida, lo que permite al usuario tomar decisiones sobre su entorno sin necesidad de
utilizar la visión.

Este proyecto combina conocimientos en programación digital con hardware embebido, lógica
secuencial y combinacional. También se usaron los conocimientos adquiridos para la codificación
en Verilog HDL, control de dispositivos externos y diseño e integración de sistemas de asistencia.
A lo largo del desarrollo se enfrentaron retos relacionados con la sincronización de señales, la
medición de tiempo con alta resolución y el diseño de señales PWM ajustables.

# Arquitectura implementada

La arquitectura del sistema se basó en un diseño completamente modular, y se conecta de manera
coherente para su correcto funcionamiento, y esto es conseguir la emisión del pulso ultrasónico
hasta la señalización de alerta háptica y sonora como se ve en la siguiente imagen.


<p align="center">
        <img src="/media/Imagen1.png" alt="alt text" width=500 >
    </p>

 Al principio, un divisor de frecuencia toma el reloj principal de la FPGA y lo reduce para alimentar con la frecuencia adecuada al sensor ultrasónico y  se usa otro divisor de frecuencia para los generadores de los PWM. Esto garantiza que el pulso de disparo enviado al HC-SR04 tenga el ancho y la cadencia correctos además de controlar con precisión la resolución temporal del conteo de eco. con la siguiente arquitectura.

<p align="center">
        <img src="/media/Imagen2.png" alt="alt text" width=500 >
    </p>


en donde está incluido el divisor de frecuencia del sensor.
El bloque encargado de la medición envía un breve pulso al sensor, espera el retorno y mide el tiempo en que dicha señal permanece activa. Ese tiempo se traduce internamente a un valor de distancia en centímetros mediante operaciones aritméticas para calibrar el sensor y optimizar el hardware hasta que la lectura sea válida, el valor calculado se pasa a un escalador que configurado de la forma:


<p align="center">
        <img src="/media/Imagen3.png" alt="alt text" width=500 >
    </p>

 Que según la proximidad del obstáculo, genera un número proporcional al nivel de alerta deseado en un valor de 0 a 255.
Después, ese nivel alimenta el PWM para el buzzer piezoeléctrico y otro para el motor de vibración usando la misma configuración teniendo el siguiente bloque para ambos casos.

<p align="center">
        <img src="/media/Imagen4.png" alt="alt text" width=500 >
    </p>

Conforme algún objeto se acerque, el duty cycle de ambas señales aumenta, produciendo un pitido más sonoro y una vibración más intensa. El buzzer se conecta directamente a la FPGA y el motor va a un controlador de potencia para no tener problemas de potencia dentro de la FPGA y manteniendo la lógica aislada de cargas altas. Mientras tanto, el sistema incluye dos salidas de visualización, un conjunto de displays de siete segmentos para mostrar los centímetros de distancia en dígitos con el circuito:


<p align="center">
        <img src="/media/Imagen5.png" alt="alt text" width=500 >
    </p>

 y la pantalla LCD para reflejar los valores del PWM es decir de 0 a 255 usando el circuito:

<p align="center">
        <img src="/media/Imagen6.png" alt="alt text" width=500 >
    </p>


De esta manera hay un flujo que comienza en el divisor del clock para después pasar por la medición y conversión de esta distancia que se traduce en un duty cycle del PWM conectado al puente H para la generación del pitido de alerta con relación a la entrada del sensor conectado directamente a la FPGA.

dando un total de 748 elementos lógicos, 144 registros y 31 pines usados para el proyecto.


# Pruebas


 Una vez implementado se hacen pruebas del funcionamiento correcto en FPGA donde tiene un alcance considerable para una generación de alerta de una posible futura colisión, y para esta seguros de esto y de no tener en cuenta mediciones inestables o falsos positivos, optamos por tener un comportamiento seguro dentro del rango de 100 centímetros que generan las salidas esperadas del sistema de alerta.


<p align="center">
        <img src="/media/Imagen7.png" alt="alt text" width=500 >
    </p>

En la siguiente imagen se observan las mediciones tomadas y desplegadas en los siete segmentos y la LCD

<p align="center">
        <img src="/media/Imagen8.png" alt="alt text" width=500 >
    </p>

# Uso de Inteligencia Artificial
 


El uso de inteligencia artificial es de gran ayuda cuando queremos encontrar información que desconocemos o simplemente ayudarnos a entender los retos y obstáculos que debemos enfrentar ya que muchas veces nos ayuda a encontrar y depurar errores en nuestro proceso de diseño a lo largo de nuestro desarrollo, por ejemplo, hubo un momento de estancamiento en la calibración del sensor de ultrasonido en donde la ayuda en la corrección del código en Verilog fue clave para entender su funcionamiento completo y de igual manera el error existente en la implementación. 



En resumen el uso de inteligencia artificial es de carácter práctico en el entendimiento de nuevos temas dentro de un contexto complejo de desarrollo y académico para el entendimiento y la retroalimentación detrás de algún error o desconocimiento existente en nuestro proceso.



# Conclusiones

El desarrollo de SOMA nos demostró la viabilidad de emplear la lógica digital en FPGA para resolver un problema de accesibilidad real, además de destacar la importancia de la integración de los modelos de acuerdo a sus especificaciones teóricas y técnicas para el correcto acople en un flujo de datos continuo.

La comprobación de cada módulo en cada etapa del diseño ha sido clave para comprender las problemáticas comunes en este tipo de proyectos, además de permitirnos resolver problemas relacionados a la sincronización de las señales y la gestión de los clocks, siendo un práctica efectiva para la detección de errores y también nos permite ampliar funcionalidades.

Aunque el sistema aún no cuenta con un modelo comercial, fue clave determinar los pasos a seguir para determinar y diseñar un proyecto con rentabilidad económica además de generar un aporte a la sociedad, un impacto real y positivo a partir de un proyecto académico.


Con un punto de vista académico e investigativo, SOMA nos permitió aplicar y reforzar conceptos avanzados de diseño digital, generación de señales y un correcto procesamiento de las mismas, que nos permite identificar la escalabilidad que podemos realizar en este tipo de proyectos académicos.



Finalmente, queremos destacar la importancia del buen manejo del tiempo y de la correcta comunicación en el grupo de trabajo para desarrollar de manera exitosa un proyecto en ingeniería y en general cualquier trabajo conjunto dentro o fuera de la institución.

# Bibliografía



Intel Corporation. (2013). Cyclone IV Device Handbook (Versión 5.1). https://www.intel.com


SparkFun Electronics. (2014). HC-SR04 Ultrasonic Sensor Datasheet. https://www.sparkfun.com


STMicroelectronics. (2007). L298N Dual H-Bridge Motor Driver Datasheet (Rev. 9). https://www.st.com


Altera Corporation. (2013). Quartus II Software User Guide. https://www.intel.com


Mentor Graphics. (2020). ModelSim Verification and Debugging Tool User Guide. https://www.mentor.com


Mano, M. M. (2012). Digital design (5ª ed.). Prentice Hall.


Palnitkar, S. (2003). Verilog HDL: A guide to digital design and synthesis (2ª ed.). Prentice Hall.


Lee, T. (2012). Design with operational amplifiers and analog integrated circuits (4ª ed.). McGraw-Hill.


Smith, J., & Garcia, L. (2024). High-resolution distance measurement with HC-SR04 and FPGA. Journal of Embedded Systems, 8(2), 45–52.

# video de funcionamiento.

https://drive.google.com/drive/folders/1rQF4W5LrGwnc31Y5G6gPLh74Duq-4310

