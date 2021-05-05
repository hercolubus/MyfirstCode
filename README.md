
<img src="https://github.com/hercolubus/MyfirstCode/blob/master/dxc%20image.png" height="130" width="900" ></img>


# Laboratorio de Terraform MyfirstCode

## Alcance

El proposito de este laboratorio es crear infrastrutura en azure a traves de template de terraform en esa ocasion hacuendo
 uso de las  creadenciales de AZURE atraves de az cli


<img src="https://github.com/hercolubus/MyfirstCode/blob/master/dxc%20image.png" height="130" width="900" ></img>

## Requisitos

Se deben descargar e instalar los siguientes aplicativos:

- Instalación y configuración de [Git](https://git-scm.com/downloads)
- Instalación y configuración de [Azure Cli](https://git-scm.com/downloads)
- Instalación de [Terraform](https://www.terraform.io/downloads.html)
- Instalación de algún IDE [Atom](https://atom.io)


## Configuración
Se debe clonar el siguiente [repositorio](hercolubus/MyfirstCode.git)


```shell
mkdir Repo
cd Repo
git clone git@github.com:hercolubus/MyfirstCode.git

Cloning into 'MyfirstCode'...
remote: Enumerating objects: 4, done.
remote: Counting objects: 100% (4/4), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 4 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (4/4), done.

```
Una vez clonado el repositorio se debe ingresar al directorio creado y editar el archivo variables.tf para cambiar los valores de las variables.

Ejemplo:

```tf
variable "subscription_id" {
  description = "Suscription ID"
  type        = string
  default     = "Change Me" // cambiar valor por el suscription id
  sensitive   = true
}

variable "tag" {
  description = "tag"
  type        = string
  default     = "Grupo DevOps" // cambiar valor por un tag único ejemplo Grupo DevOps C
}

variable "rsgroup" {
  description = "Resource Group"
  type        = string
  default     = "DevOps" // cambiar valor por un grupo de recursos único ejemplo DevOps C
}

```

## Despliegue de infraestructura

Ya realizados los cambios se debe ejecutar terraform


```tf
terraform init

```

el resultado esperado es:

```shell

> $ terraform init                                                                                                                               [±master ●]

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 2.0"...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/tls...
- Installing hashicorp/azurerm v2.56.0...
- Installed hashicorp/azurerm v2.56.0 (self-signed, key ID 34365D9472D7468F)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (self-signed, key ID 34365D9472D7468F)
- Installing hashicorp/tls v3.1.0...
- Installed hashicorp/tls v3.1.0 (self-signed, key ID 34365D9472D7468F)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

Ahora ejecutar terraform plan


```shell
terraform plan

```

El resultado de la ejecución debería entregar un resultado como el siguiente


```shell
terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.linuxvm01 will be created
  + resource "azurerm_linux_virtual_machine" "linuxvm01" {
      + admin_username                  = "azureuser"
      + allow_extension_operations      = true
      + computer_name                   = "linuxvm01"
      + disable_password_authentication = true
  .
  .
  .
  .
  .
  .

  Plan: 14 to add, 0 to change, 0 to destroy.

  Changes to Outputs:
    + azurerm_linux_virtual_machine = (known after apply)
    + tls_private_key               = (known after apply)

```

Ahora se debe revisar que lo entregado por terraform plan corresponda a lo que efectivamente a la infraestructura que necesitamos crear. De ser así podemos continuar con la ejecución de nuestra infraestructura con terraform apply


```shell
terraform apply

```

Nos preguntara si estamos seguros o no de continuar con la creación: escribimos yes


```shell

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:


```

El resultado esperado es

```shell

azurerm_linux_virtual_machine.linuxvm01: Still creating... [10s elapsed]
azurerm_windows_virtual_machine.windowsVM: Still creating... [20s elapsed]
azurerm_linux_virtual_machine.linuxvm01: Still creating... [20s elapsed]
azurerm_windows_virtual_machine.windowsVM: Still creating... [30s elapsed]
azurerm_linux_virtual_machine.linuxvm01: Still creating... [30s elapsed]

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

```


Ahora al revisar nuestra infraestructura en azure podemos ver que se genero la siguiente topología

<img src="https://github.com/hercolubus/MyfirstCode/blob/master/Topologia.png" height="500" width="900" ></img>
