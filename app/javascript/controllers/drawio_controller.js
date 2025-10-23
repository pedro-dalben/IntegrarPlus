import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iframe", "saveIndicator", "saveStatus", "versionNotes"]
  static values = {
    flowChartId: Number,
    updateUrl: String,
    exportUrl: String,
    initialData: String
  }

  connect() {
    this.boundHandleMessage = this.handleMessage.bind(this)
    window.addEventListener("message", this.boundHandleMessage)

    this.iframe = this.iframeTarget
    this.diagramLoaded = false
    this.currentXml = this.initialDataValue || this.getEmptyDiagram()

    this.iframe.addEventListener("load", () => {
      console.log("Draw.io iframe loaded")
    })
  }

  disconnect() {
    window.removeEventListener("message", this.boundHandleMessage)
  }

  handleMessage(event) {
    if (!event.data || typeof event.data !== "string") return

    try {
      const message = JSON.parse(event.data)

      switch(message.event) {
        case "init":
          this.handleInit()
          break
        case "autosave":
        case "save":
          this.handleSaveEvent(message)
          break
        case "export":
          this.handleExport(message)
          break
        case "configure":
          this.handleConfigure()
          break
      }
    } catch (e) {
      console.error("Error parsing message:", e)
    }
  }

  handleInit() {
    console.log("Draw.io initialized, loading diagram...")
    this.loadDiagram()
  }

  handleSaveEvent(message) {
    if (message.xml) {
      this.currentXml = message.xml
      console.log("Diagram auto-saved in memory")
    }
  }

  handleExport(message) {
    if (message.data) {
      const format = message.format || "png"
      this.downloadFile(message.data, `fluxograma-${this.flowChartIdValue}.${format}`)
    }
  }

  handleConfigure() {
    this.sendMessage({
      action: "configure",
      config: {
        defaultLibraries: "general;uml;er;bpmn",
        autosave: 1,
        saveAndExit: false
      }
    })
  }

  loadDiagram() {
    if (this.diagramLoaded) return

    const xml = this.currentXml
    console.log("Loading diagram with data:", xml ? "present" : "empty")

    this.sendMessage({
      action: "load",
      xml: xml,
      autosave: 1
    })

    this.diagramLoaded = true
  }

  save(event) {
    event.preventDefault()

    this.showSaveIndicator()
    this.updateSaveStatus("Solicitando dados do diagrama...")

    this.sendMessage({
      action: "export",
      format: "xml"
    })

    setTimeout(() => {
      this.saveDiagram()
    }, 1000)
  }

  async saveDiagram() {
    try {
      this.updateSaveStatus("Salvando versão...")

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const versionNotes = this.hasVersionNotesTarget ? this.versionNotesTarget.value : ""

      const formData = new FormData()
      formData.append("diagram_data", this.currentXml)
      formData.append("version_notes", versionNotes)

      const response = await fetch(this.updateUrlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        this.updateSaveStatus("Versão salva com sucesso!")
        this.hideSaveIndicator()

        if (this.hasVersionNotesTarget) {
          this.versionNotesTarget.value = ""
        }

        setTimeout(() => {
          window.location.reload()
        }, 1000)
      } else {
        throw new Error("Erro ao salvar")
      }
    } catch (error) {
      console.error("Error saving diagram:", error)
      this.updateSaveStatus("Erro ao salvar. Tente novamente.")
      this.hideSaveIndicator()
    }
  }

  exportPNG(event) {
    event.preventDefault()
    this.updateSaveStatus("Exportando PNG...")

    this.sendMessage({
      action: "export",
      format: "png",
      embedImages: true
    })

    setTimeout(() => {
      this.updateSaveStatus("")
    }, 2000)
  }

  exportSVG(event) {
    event.preventDefault()
    this.updateSaveStatus("Exportando SVG...")

    this.sendMessage({
      action: "export",
      format: "svg",
      embedImages: true
    })

    setTimeout(() => {
      this.updateSaveStatus("")
    }, 2000)
  }

  exportPDF(event) {
    event.preventDefault()
    this.updateSaveStatus("Exportando PDF...")

    this.sendMessage({
      action: "export",
      format: "pdf"
    })

    setTimeout(() => {
      this.updateSaveStatus("")
    }, 2000)
  }

  sendMessage(message) {
    if (!this.iframe || !this.iframe.contentWindow) {
      console.error("Iframe not ready")
      return
    }

    this.iframe.contentWindow.postMessage(JSON.stringify(message), "*")
  }

  downloadFile(dataUri, filename) {
    const link = document.createElement("a")
    link.href = dataUri
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    this.updateSaveStatus("Download iniciado!")
    setTimeout(() => {
      this.updateSaveStatus("")
    }, 2000)
  }

  showSaveIndicator() {
    if (this.hasSaveIndicatorTarget) {
      this.saveIndicatorTarget.classList.remove("hidden")
    }
  }

  hideSaveIndicator() {
    if (this.hasSaveIndicatorTarget) {
      this.saveIndicatorTarget.classList.add("hidden")
    }
  }

  updateSaveStatus(message) {
    if (this.hasSaveStatusTarget) {
      this.saveStatusTarget.textContent = message
    }
  }

  getEmptyDiagram() {
    return `<mxfile host="embed.diagrams.net" modified="${new Date().toISOString()}" agent="IntegrarPlus" version="1.0.0" etag="" type="embed">
  <diagram name="Page-1" id="page-1">
    <mxGraphModel dx="800" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>`
  }
}
