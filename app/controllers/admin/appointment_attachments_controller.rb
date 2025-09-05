class Admin::AppointmentAttachmentsController < Admin::BaseController
  before_action :set_appointment_attachment, only: [:show, :download, :destroy]
  before_action :set_medical_appointment
  before_action :authorize_appointment_attachment

  def index
    @appointment_attachments = @medical_appointment.appointment_attachments.includes(:uploaded_by).order(created_at: :desc)
  end

  def show
  end

  def new
    @appointment_attachment = @medical_appointment.appointment_attachments.build
  end

  def create
    @appointment_attachment = @medical_appointment.appointment_attachments.build(appointment_attachment_params)
    @appointment_attachment.uploaded_by = current_user

    if @appointment_attachment.save
      redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Anexo adicionado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def download
    if @appointment_attachment.can_be_downloaded_by?(current_user)
      redirect_to @appointment_attachment.download_url
    else
      redirect_to admin_medical_appointment_path(@medical_appointment), alert: 'Você não tem permissão para baixar este arquivo.'
    end
  end

  def destroy
    if @appointment_attachment.can_be_deleted_by?(current_user)
      @appointment_attachment.destroy
      redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Anexo removido com sucesso.'
    else
      redirect_to admin_medical_appointment_path(@medical_appointment), alert: 'Você não tem permissão para remover este anexo.'
    end
  end

  private

  def set_appointment_attachment
    @appointment_attachment = AppointmentAttachment.find(params[:id])
  end

  def set_medical_appointment
    @medical_appointment = MedicalAppointment.find(params[:medical_appointment_id])
  end

  def authorize_appointment_attachment
    authorize :appointment_attachment, :index?
  end

  def appointment_attachment_params
    params.require(:appointment_attachment).permit(:attachment_type, :name, :file)
  end
end
