# Conceptos del Proyecto: Terraform Multi-Environment con Terragrunt

Este documento explica la arquitectura conceptual detrás de este repositorio. Aunque el objetivo final de este proyecto es simplemente **desplegar un Bucket de S3**, su verdadero propósito es demostrar una **estrategia robusta y escalable para gestionar múltiples entornos** (Desarrollo, QA, Producción) utilizando Terraform y Terragrunt.

---

## 1. La Estrategia Multi-Ambiente

En el desarrollo de software moderno, nunca desplegamos cambios directamente en Producción. Necesitamos entornos separados y aislados para probar las cosas de forma segura.

Este repositorio divide la infraestructura en tres entornos distintos (aislados idealmente en cuentas de AWS diferentes):
*   **Dev (`dev`)**: Donde los desarrolladores prueban los cambios libremente.
*   **QA (`qa`)**: Un entorno estable para pruebas de integración y validación de calidad.
*   **Producción (`prod`)**: El entorno en vivo que sirve a los usuarios finales.

**El reto con Terraform puro:** 
Si usáramos solo Terraform, tendríamos que copiar y pegar el código de creación del bucket S3 en las tres carpetas. Si mañana decidimos que todos los buckets deben estar encriptados con KMS, tendríamos que editar el código en tres lugares diferentes (lo cual es propenso a errores y viola el principio DRY - *Don't Repeat Yourself*).

---

## 2. El Propósito de Terragrunt (Arquitectura DRY)

Para resolver el problema de la repetición, utilizamos **Terragrunt**, una herramienta que envuelve a Terraform y nos permite separar completamente la "receta" de los "ingredientes".

Gracias a Terragrunt, logramos lo siguiente:
1.  **Código centralizado (La Receta)**: El código Terraform real se escribe una sola vez.
2.  **Configuraciones dinámicas (Los Ingredientes)**: Cada entorno solo define los valores que cambian (como el ID de la cuenta de AWS o el nombre del entorno).
3.  **Backend DRY**: La configuración del backend (dónde se guarda el estado de Terraform, es decir, el archivo `.tfstate`) se define una sola vez y se hereda dinámicamente a todos los entornos.

---

## 3. Estructura de Archivos Principales

A continuación se detalla el propósito de los archivos clave bajo esta arquitectura DRY:

### El Módulo (El Código Real)
*   **`modules/s3_bucket/main.tf`**: Este es el único lugar donde existe código de Terraform real. Define cómo se crea un bucket de S3. Ningún entorno (`dev`, `qa`, `prod`) contiene archivos `.tf`.

### La Orquestación (Terragrunt)
*   **`environments/terragrunt.hcl` (El Padre)**: 
    Es el archivo maestro. Contiene la configuración del `remote_state` (el backend de S3 y la tabla de bloqueos en DynamoDB). Utiliza variables dinámicas para que, dependiendo de desde qué carpeta se ejecute, sepa exactamente qué bucket de estado usar. Todos los entornos heredan de este archivo.

*   **`environments/<env>/env.hcl` (Las Variables del Entorno)**: 
    Cada entorno tiene este archivo. Define propiedades únicas como `environment = "dev"` y el `aws_account_id`. El archivo padre lee estos valores para configurar el backend y los proveedores automáticamente.

*   **`environments/<env>/terragrunt.hcl` (El Ejecutor)**: 
    Es el archivo de entrada para cada entorno. Es extremadamente ligero: solo tiene un bloque `include` (que dice "hereda todo del padre") y un bloque `terraform` (que dice "ve a buscar el módulo de s3_bucket y ejecútalo").

---

## 4. Flujo de Trabajo Resumido

Cuando ejecutas `terragrunt apply` dentro de `environments/dev`:
1.  Terragrunt lee `environments/dev/terragrunt.hcl`.
2.  Ve la instrucción `include` y sube a leer el padre `environments/terragrunt.hcl`.
3.  El padre lee las variables específicas de `environments/dev/env.hcl`.
4.  Terragrunt auto-genera el archivo `backend.tf` con el bucket de estado correcto para la cuenta de Dev.
5.  Terragrunt descarga el código del módulo `modules/s3_bucket` en una carpeta temporal (`.terragrunt-cache`).
6.  Finalmente, ejecuta `terraform apply` sobre ese módulo temporal.
