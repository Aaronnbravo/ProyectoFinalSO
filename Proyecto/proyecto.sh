#!/bin/bash

# Colores
NC='\033[0m' # Sin color
RED='\033[0;31m' # Rojo
GREEN='\033[0;32m' # Verde
YELLOW='\033[0;33m' # Amarillo
BLUE='\033[0;34m' # Azul

# Función para generar un informe del uso de recursos
generate_report() {
    timestamp=$(date +"%Y%m%d_%H%M%S") # Obtiene la fecha y hora actual
    report_file="uso_recursos_$timestamp.log" # Usa la fecha en el nombre del archivo

    echo -e "${BLUE}Generando informe de uso de recursos...${NC}"
    echo "Uso de CPU, Memoria y Disco" > "$report_file"
    echo "===================================" >> "$report_file"
    echo -e "${YELLOW}Uso de CPU:${NC}" >> "$report_file"
    top -b -n1 | grep "Cpu(s)" >> "$report_file"
    echo "" >> "$report_file"
    echo -e "${YELLOW}Uso de Memoria:${NC}" >> "$report_file"
    free -h >> "$report_file"
    echo "" >> "$report_file"
    echo -e "${YELLOW}Uso de Disco:${NC}" >> "$report_file"
    df -h >> "$report_file"
    echo -e "${GREEN}Informe guardado en $report_file.${NC}"
}

# Función para verificar e instalar actualizaciones del sistema
install_updates() {
    echo -e "${BLUE}Verificando e instalando actualizaciones del sistema...${NC}"
    sudo apt update &>> actualizaciones.log
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y &>> actualizaciones.log
    echo -e "${GREEN}Actualizaciones instaladas y registradas en actualizaciones.log.${NC}"
}

# Función para eliminar archivos temporales y caché
clean_temp_files() {
    echo -e "${BLUE}Eliminando archivos temporales y caché...${NC}"
    sudo apt-get clean
    rm -rf ~/.cache/*
    echo -e "${GREEN}Archivos temporales y caché eliminados.${NC}"
}

# Función para respaldar un directorio en un archivo comprimido
backup_directory() {
    read -p "Ingresa el directorio que deseas respaldar: " directory
    if [ ! -d "$directory" ]; then
        echo -e "${RED}El directorio no existe. Por favor, verifica la ruta.${NC}"
        return
    fi

    backup_dir="backups"
    mkdir -p "$backup_dir"

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="$backup_dir/backup_$(basename "$directory")_$timestamp.tar.gz"

    echo -e "${BLUE}Generando el respaldo...${NC}"
    tar -czf "$backup_file" "$directory"
    echo -e "${GREEN}Respaldo generado: $backup_file${NC}"

    read -p "¿Cuántos días deseas conservar los backups? (Por defecto: 7): " days
    days=${days:-7}
    find "$backup_dir" -type f -name "*.tar.gz" -mtime +$days -exec rm -f {} \;
    echo -e "${YELLOW}Backups antiguos eliminados (más de $days días).${NC}"
}

# Función para crear un usuario nuevo y gestionar permisos
create_user() {
    read -p "Ingresa el nombre del nuevo usuario: " username

    if id "$username" &>/dev/null; then
        echo -e "${RED}El usuario '$username' ya existe.${NC}"
        return
    fi

    sudo adduser "$username"
    echo -e "${GREEN}Usuario '$username' creado exitosamente.${NC}"

    echo -e "${BLUE}Configurando permisos y directorio personal...${NC}"
    sudo chmod 700 /home/"$username"
    echo -e "${GREEN}Directorio personal asegurado para el usuario '$username'.${NC}"

    read -p "¿Deseas agregar al usuario a algún grupo adicional? (y/n): " add_group
    if [[ "$add_group" == "y" || "$add_group" == "Y" ]]; then
        read -p "Ingresa el nombre del grupo: " group
        if getent group "$group" &>/dev/null; then
            sudo usermod -aG "$group" "$username"
            echo -e "${GREEN}Usuario '$username' añadido al grupo '$group'.${NC}"
        else
            echo -e "${RED}El grupo '$group' no existe.${NC}"
        fi
    fi

    echo -e "${BLUE}Detalles del usuario creado:${NC}"
    id "$username"
}

# Menú interactivo
while true; do
    echo -e "${BLUE}=== Menú de inicio ===${NC}"
    echo "1. Generar informe de uso de recursos"
    echo "2. Verificar e instalar actualizaciones del sistema"
    echo "3. Eliminar archivos temporales y caché"
    echo "4. Automatizar respaldo de un directorio"
    echo "5. Crear usuario nuevo y gestionar permisos"
    echo "6. Salir"
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1)
            generate_report
            ;;
        2)
            install_updates
            ;;
        3)
            clean_temp_files
            ;;
        4)
            backup_directory
            ;;
        5)
            create_user
            ;;
        6)
            echo -e "${RED}Saliendo...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opción no válida. Por favor, selecciona otra opción.${NC}"
            ;;
    esac
    echo
done
