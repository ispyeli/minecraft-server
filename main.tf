terraform {
  required_providers {
    fly = {
      source = "andrewbaxter/fly"
      version = "0.1.13"
    }
  }
}

provider "fly" {}

resource "fly_app" "minecraft" {
  name = "seve-minecraft"
  org = "personal"
}

resource "fly_volume" "mc_volume" {
  app = "seve-minecraft"
  name = "mc_volume"
  size = 15
  region = "sjc"

  depends_on = [fly_app.minecraft]
}

resource "fly_ip" "mcIP" {
  app = "seve-minecraft"
  type = "v4"

  depends_on = [fly_app.minecraft]
}

resource "fly_machine" "mcServer" {
  name = "mc-server"
  region = "sjc"
  app = "seve-minecraft"
  image  = "itzg/minecraft-server:latest"

  env = {
    EULA                    = "TRUE"
    ENABLE_AUTOSTOP         = "TRUE"
    AUTOSTOP_TIMEOUT_EST    = 120
    AUTOSTOP_TIMEOUT_INIT   = 120
    MEMORY                  = "7G"
    AUTOSTOP_PKILL_USE_SUDO = "TRUE"
    TYPE                    = "MODRINTH"
    MODRINTH_MODPACK        = "https://modrinth.com/modpack/fabulously-optimized"
    MODRINTH_PROJECTS       = "plasmo-voice, no-chat-reports, double-doors, villager-names-serilum, spawn-animations, dynamic-lights, appleskin, inventory-sorting, universal-graves"
    MODRINTH_DOWNLOAD_DEPENDENCIES = "optional"
    WHITELIST_FILE = "https://github.com/seve/minecraft-server/raw/main/whitelist.txt"
    EXISTING_WHITELIST_FILE = "SYNCHRONIZE"
    ENFORCE_WHITELIST = "TRUE"
    OPS = "S33V"
  }

 services = [
    {
      ports = [
        {
          port = 25565
        }
      ]
      protocol      = "tcp"
      internal_port = 25565
    }
  ]

  mounts = [
    { path   = "/data"
      volume = fly_volume.mc_volume.id
    }
  ]

  cpus     = 4
  memory = 8192

  depends_on = [fly_volume.mc_volume, fly_app.minecraft]
}