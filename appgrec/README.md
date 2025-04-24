# appgrec

Aplicación móvil Flutter para la gestión y participación en sorteos.

## Descripción:

appgrec es una aplicación desarrollada en Flutter que permite a los usuarios registrarse, participar en sorteos mediante el escaneo de códigos QR, consultar premios ganados y visualizar su historial de participaciones.
Está diseñada para funcionar con Firebase Authentication y un backend desarrollado en Node.js, conectado a una base de datos MySQL.

## Características principales:

Autenticación de usuarios con Firebase.

Escaneo de códigos QR para participar en sorteos.

Asignación y edición de premios desde un panel de administración.

Gestión de sorteos y Realización de sorteos .

Historial de participaciones y premios ganados.

Soporte para múltiples roles de usuario (cliente, administrador).

## Tecnologías utilizadas:

Flutter

Firebase Authentication

Node.js (Express)

MySQL (vía Sequelize)

flutter_dotenv

Custom Widgets para diseño consistente

## Getting Started

Sigue estos pasos para configurar y ejecutar appgrec en tu máquina local.

## Requisitos previos
Asegúrate de tener instalados los siguientes programas:

Flutter: Sigue esta guía para instalar Flutter en tu sistema.

Node.js: Asegúrate de tener Node.js instalado. Puedes descargarlo desde aquí.

MySQL: Asegúrate de tener MySQL en tu sistema o usa un servicio de base de datos en la nube.

## Configuración de Firebase
Crea un proyecto en Firebase.

Habilita Firebase Authentication en el proyecto.

Configura la autenticación con correo y contraseña.

Descarga el archivo google-services.json (para Android) y configúralo en tu proyecto Flutter (en android/app).

Si usas otras funcionalidades de Firebase (como Firestore, Storage, etc.), configúralas también en la consola de Firebase.


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


____________________________________________
para cambiar el nombre del package.
flutter pub run change_app_package_name:main com.nombre.nombre