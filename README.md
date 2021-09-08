# Introducción
Este dotfiles pretende cumplir dos funciones:

* Almacen de toda la configuración.
* Gestión de la instalación de todo el software de forma que se pueda replicar en nuevas máquinas.

Agradecimientos en particular para los [Dotfiles de Holman](https://github.com/holman/dotfiles), que se pueden encontrar aquí, y en cuya estructura está basado este repositorio:

## Instalación

0. Copiar las claves de ssh para poder descargarme todos los repositorios

1. Descargar el repositorio en `~/.dotfiles`. Normalmente los dotfiles suelen ir en el $HOME del directorio en el que se está ejecutando.

```shell
git@gitlab.com:autentia/internal/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Aplicar los cambios de configuración:

```shell
make setup
```

3. Ya está todo tu proyecto configurado. A continuación se explica el funcionamiento del los comandos

## Dotfiles

La ejecución de la configuración está basada en el script de nombre `dotfiles`.
Este script tiene varios comandos que son explicados a continuación
A continuación la explicación de

* `dotfiles install`: Busca todos los ficheros llamados `install.sh` que haya dentro del dotfiles y los ejecuta.
Con esto puedes separar los procesos de instalación de cada una de tus herramientasy tenerlos de manera replicada.

> El propósito de este comando es que se ejeucte con frecuencia para tener tu sistema y todas herramientas gestionadas por este repositorio actualizadas

* `dotfiles bin-path`: Busca todos los ficheros dentro de los directorios bin del repositorio dotfiles y crea un enlace simbólico con `/usr/local/bin` para que sean accesibles.

* `dotfiles symlink`: Busca todos los ficheros que cumplan la expresión `*.symlink` para hacer un enlace simbólico en $HOME.
Mucha configuración requiere o se busca por defecto en $HOME pero nosotros queremos tenerla versionada y de esta forma podemos conseguirlo.

* `dotfiles git-setup`: Configura la línea de comandos de Git con tu usuario y correo para firmar tus commits cuando estés usando git desde la terminal.

> Estos comandos son pensados para ser idempotentes. EX. Todos los script de instalación que crees deben poder ejecutarse siempre sin dar fallos

## Estructura y funcionamiento

La jerarquía de los ficheros es importante a la hora de gestionar la configuración, de forma que te permite tener separados distintos apartados por tópicos, aislando el impacto de distintas configuraciones.

A cada uno de los directorios lo llamaremos «tópico». Estos tópicos pueden ir desde software a directorios con información específica del proyecto con el que estes trabajando.
La estructura de estos tópicos es:

- **macos/Brewfile**: Esta es una lista de las apliaciones que serán instaladas con Homebrew [Homebrew Cask](http://caskroom.io). Podrías querer editar este fichero antes de hacer la instalación.
Por defecto siempre trataremos de instalar todo con el gestor de paquetes HomeBrew y este fichero dirá el software que tenemos.

- **topic/bin/**: Cualquier cosa dentro de un directorio bin dentro del repositorio será añadida al $PATH, estando disponible en cualquier lugar desde la terminal usando el comando `dotfiles bin-path`.

> NOTA: El script de dotfiles está dentro de un directorio bin para que después de la primera ejecución pueda ser ejecutado desde cualquier sitio en la terminal.

- **topic/install.sh**: Cualquier fichero llamado `install.sh` serán ejecutado cuando se ejecute la instalación del sistema. Para que no se cargue de forma automática, la extensión es .sh y no .zsh

> NOTA: A lo que se con la extensión .sh es que por defecto todos los ficheros con extensión .zsh se cargan como parte del proceso de la shell de zsh.

- **topic/\<FILENAME | DIRNAME>.symlink**: Cualquier fichero o directorio que termine en `*.symlink` será puesto como un enlace simbólico en tu $HOME. De esta forma, puedes mantener versionados tus dotfiles, pero cargarlos de forma automática en tu $HOME.

Con las siguientes propiedades si tuvieras que añadir la instalación de un nuevo tópico como kubernetes podrias:

* Crear un directorio "kubernetes" en la raiz de dotfiles y dentro:
    * Crear fichero "install.sh" que tenga el proceso de instalación si no está en HomeBrew.
    * Crear fichero "alias.zsh" para crear alias para el uso de Kubernetes en tu terminal. Este será cargado de forma automatica por tu zshrc al entrar en una nueva terminal.
    * Crear fichero "functions.zsh" para crear funciones para el uso de Kubernetes en tu terminal. Este será cargado de forma automatica.

    >  Podrías crear un solo fichero pero es recomendable tener en distintos ficheros acciones distintas. A tu zsh lo único que le importa es la extenxión.

    * Crear un directorio llamado ".kube.symlink" para que se cree en tu home un enlace simbólico llamado .kube. Con esto todos los ficheros que incluyas dentro del repositorio se ven reflejados en tu Home.

    > Como se ve aquí, el uso de los symlinks no aplica solo a ficheros, sino también a directorios.

Otro ejemplo podría ser en lugar de un tópico de una nueva herramienta crear uno para almacenar la configuración especifica de un cliente.

* **projects/project_name**: Aquí tenemos directorios por cada uno de los proyectos que necesiten configuración específica. En todos los ficheros usamos un prefijo por proyecto para poder identificar las funciones que usamos por cada proyecto.
    - **alias.sh**: Fichero con los alias que usamos en este projecto.
    - **functions.zsh**: Fichero con las funciones específicas. Aquí usamos como convención.
    - **bin/project_custom_executable**: Ejecutable que se añadirá al path y que es propio del cliente
    - **install.sh**: Instalación de requerimieentos específicos para un cliente.

> El directorio projects no se debe subir a ningún repositorio ya que tiene información sensible y es opcional crearlo. En el .gitignore está añadido este directorio para evitar subidas accidentales.


## Creación de funciones auxiliares

Todas las funciones auxiliares estan dentro del directorio libexec/helpers.
La intención de este directorio es almacenar todas las funciones que vayan a utilizar los scripts de dotfiles, de forma que sea sencillo actualizar funciones específicas o incluso una migración posterior a Python :D

De esta forma, si queremos crear una nueva función en un nuevo fichero «functions_example» una plantilla sería añadir:

```shell
#!/bin/bash

# file: $HOME/.dotfiles/libexec/helpers

example_function(){
    info_msg 'Prueba de concepto'
    ls -lahtr

    success_msg 'Biers'

    # La variable $script_file y la variable $script_dir siempre están disponibles, se actualizan cada vez que ejecutas el método «set_debug_file_label» y nos permiten no tener que estar definiendo variables distintas para trazar en qué fichero estamos. Ya están definidas y podemos usarlas.
    debug_msg "[$script_file] Probar algo que seguro que falla

    # La función fail_msg por defecto termina la ejecución del programa de forma directa.
    fail_msg "Cómo esperamos falló. ADIOS"
}
```

## Añadir nuevos comandos a dotfiles

La herramienta de dotfiles puede extenderse de la siguiente forma:

1. Crear fichero `libexec/dotfiles-<command-name>` con la siguiente estructura:

```bash
#!/usr/bin/env bash

# Summary: <++>
#
# <++>

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DOTFILES_ROOT="${1:?Usage: dotfiles-bin-path DOTFILES_ROOT_PATH}"
source "${DOTFILES_ROOT}/libexec/helpers"

<++> Command actions
```

La estructura del fichero es:

* Comentario de qué hace y cómo funciona el comando
* Añadir bash strict mode no oficial para facilitar la depuración del script. Más información en el enlace.
* Cargar las utilidades para imprimir funciones y rutas de ejecución para depurar
* Contenido del comando.

