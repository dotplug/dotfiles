# add each topic folder to fpath so that they can add functions and completion scripts
# topic folder son todos los directorios dentro de .dotfiles
# $fpath es la variable que usa zsh para cargar las funciones que se encargan de añadir toda la chicha de autocompletar. aquí es donde zsh busca como se autocompletan las cosas
for topic_folder ($DOTFILES/*) if [ -d $topic_folder ]; then  fpath=($topic_folder $fpath); fi;
