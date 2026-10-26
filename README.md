# Turco - Gestión de Turnos de Peluquería

Aplicación móvil desarrollada en Flutter para el Primer Examen Parcial de la asignatura Programación para Dispositivos Móviles (Ingeniería Informática, 3er año).

La aplicación permite gestionar la agenda diaria de una peluquería mixta, registrar clientes, programar turnos con estilistas y llevar el control del estado de los mismos. Funciona completamente en memoria utilizando datos de prueba precargados al iniciar, sin requerir servidor, base de datos local ni autenticación.

## Requisitos Previos

- Flutter SDK instalado.
- Android Studio (o Visual Studio Code) con las extensiones de Flutter y Dart.
- Un emulador de Android o un dispositivo físico.

## Inicialización y Ejecución

Para ejecutar el proyecto en un entorno local, siga estos pasos:

1. Clone este repositorio en su máquina local.
2. Abra una terminal y ubíquese en la raíz del proyecto.
3. Ejecute el siguiente comando para descargar todas las dependencias necesarias:
   ```bash
   flutter pub get
Conecte un emulador o dispositivo Android.

Ejecute la aplicación con el comando:

bash
flutter run
Versión de Flutter Utilizada
El proyecto fue desarrollado y compilado utilizando Flutter en su canal estable (Stable), versión 3.x (compatible con Dart 3.x).

Application ID
De acuerdo con las indicaciones del profesor para esta entrega, el identificador de la aplicación (Application ID) se mantuvo con el valor generado por defecto por Flutter:

Application ID: com.example.turco

Nombre visible de la app: Turco

Cómo Generar el APK en Modo Release
Para compilar la aplicación en modo de producción, ejecute el siguiente comando en la raíz del proyecto:

bash
flutter build apk --release
El archivo APK generado se encontrará en la siguiente ruta:
build/app/outputs/flutter-apk/app-release.apk

Nota: Siguiendo las instrucciones del profesor, el archivo APK no se adjuntó en la sección de Releases de este repositorio.

Estructura de Carpetas
El proyecto sigue una arquitectura MVVM (Model-View-ViewModel) y está organizado de la siguiente manera:

lib/: Contiene todo el código fuente en Dart.

data/: Datos de prueba precargados (SeedData).

models/: Entidades del modelo de datos (Cliente, Turno, Servicio, Estilista).

router/: Configuración de navegación utilizando go_router.

theme/: Definición del tema global, paleta de colores y tipografía (modo claro y oscuro).

utils/: Funciones auxiliares y formateadores de texto y fechas.

viewmodels/: Lógica de negocio y gestión de estado (utilizando ChangeNotifier).

views/: Pantallas principales de la aplicación (Agenda, Clientes, Servicios, etc.).

widgets/: Componentes de interfaz de usuario reutilizables.

assets/: Recursos estáticos del proyecto.

fonts/: Tipografía Poppins empaquetada.

images/: Imágenes para las categorías de servicios.

avatars/: Imágenes de perfil de los estilistas.

capturas/: Capturas de pantalla reales de la aplicación en funcionamiento.

android/, ios/, web/, windows/, linux/, macos/: Carpetas de configuración nativa generadas por Flutter.

Arquitectura y Tecnologías
Framework: Flutter (Material 3).

Navegación: go_router utilizando StatefulShellRoute.indexedStack para conservar el estado de las pestañas.

Gestión de Estado: ChangeNotifier e InheritedWidget (AppScope). No se utilizan paquetes externos como Provider, Riverpod ni Bloc.

Persistencia: Los datos se mantienen en memoria durante la ejecución de la aplicación, sin persistencia local.

text

***

### Últimos pasos para finalizar

1. Pega este contenido en tu archivo `README.md` y guárdalo.
2. Abre la terminal en Android Studio y ejecuta los siguientes comandos para subir este último cambio a tu repositorio de GitHub:

```bash
git add README.md
bash
git commit -m "README finalizado con la documentacion requerida"
bash
git push origin main
