# frozen_string_literal: true

module Admin
  class AppointmentNotesController < Admin::BaseController
    before_action :set_appointment_note, only: %i[show edit update destroy]
    before_action :set_medical_appointment
    before_action :authorize_appointment_note

    def index
      @appointment_notes = @medical_appointment.appointment_notes.includes(:created_by).order(created_at: :desc)
    end

    def show; end

    def new
      @appointment_note = @medical_appointment.appointment_notes.build
    end

    def edit; end

    def create
      @appointment_note = @medical_appointment.appointment_notes.build(appointment_note_params)
      @appointment_note.created_by = current_user

      if @appointment_note.save
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Anotação criada com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @appointment_note.update(appointment_note_params)
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Anotação atualizada com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @appointment_note.can_be_deleted_by?(current_user)
        @appointment_note.destroy
        redirect_to admin_medical_appointment_path(@medical_appointment), notice: 'Anotação removida com sucesso.'
      else
        redirect_to admin_medical_appointment_path(@medical_appointment),
                    alert: 'Você não tem permissão para remover esta anotação.'
      end
    end

    private

    def set_appointment_note
      @appointment_note = AppointmentNote.find(params[:id])
    end

    def set_medical_appointment
      @medical_appointment = MedicalAppointment.find(params[:medical_appointment_id])
    end

    def authorize_appointment_note
      authorize :appointment_note, :index?
    end

    def appointment_note_params
      params.expect(appointment_note: %i[note_type content])
    end
  end
end
