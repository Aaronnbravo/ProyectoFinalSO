#!/bin/bash
# Colores
NC='\033[0m' # Sin color
RED='\033[0;31m' # Rojo
GREEN='\033[0;32m' # Verde
YELLOW='\033[0;33m' # Amarillo
BLUE='\033[0;34m' # Azul

# Función para generar un informe del uso de recursos
generate_report() {
    report_file="uso_recursos.log"
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
    sudo apt upgrade -y &>> actualizaciones.log
    echo -e "${GREEN}Actualizaciones instaladas y registradas en actualizaciones.log.${NC}"
}

# Función para eliminar archivos temporales y caché
clean_temp_files() {
    echo -e "${BLUE}Eliminando archivos temporales y caché...${NC}"
    sudo apt-get clean
    rm -rf ~/.cache/*
    echo -e "${GREEN}Archivos temporales y caché eliminados.${NC}"
}

# Menú interactivo
while true; do
    echo -e "${BLUE}=== Menú  ===${NC}"
    echo "1. Generar informe de uso de recursos"
    echo "2. Verificar e instalar actualizaciones del sistema"
    echo "3. Eliminar archivos temporales y caché"
    echo "4. Salir"
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
            echo -e "${RED}Saliendo...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opción no válida. Por favor, selecciona otra opción.${NC}"
            ;;
    esac
    echo # Línea en blanco para mejor legibilidad
done
