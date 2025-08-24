# frozen_string_literal: true

class Admin::DocumentTasksController < Admin::BaseController
  before_action :set_document
  before_action :set_task, only: %i[show edit update destroy complete reopen]

  def index
    @tasks = @document.document_tasks.includes(:created_by, :assigned_to, :completed_by)

    # Filtros
    case params[:status]
    when 'pending'
      @tasks = @tasks.where(completed_at: nil)
    when 'completed'
      @tasks = @tasks.where.not(completed_at: nil)
    end

    @tasks = @tasks.where(priority: params[:priority]) if params[:priority].present?
    if params[:assigned_to_id].present? && params[:assigned_to_id] != 'unassigned'
      @tasks = @tasks.where(assigned_to_professional_id: params[:assigned_to_id])
    end
    @tasks = @tasks.where(assigned_to_professional_id: nil) if params[:assigned_to_id] == 'unassigned'

    @pagy, @tasks = pagy(@tasks.order(created_at: :desc), items: 20)
  end

  def show
  end

  def new
    @task = @document.document_tasks.build
  end

  def edit
  end

  def create
    @task = @document.document_tasks.build(task_params)
    @task.created_by_professional_id = current_professional.id

    if @task.save
      redirect_to admin_document_document_tasks_path(@document), notice: 'Tarefa criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to admin_document_document_tasks_path(@document), notice: 'Tarefa atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to admin_document_document_tasks_path(@document), notice: 'Tarefa removida com sucesso.'
  end

  def complete
    if @task.complete!(current_professional)
      redirect_to admin_document_document_tasks_path(@document), notice: 'Tarefa marcada como concluída.'
    else
      redirect_to admin_document_document_tasks_path(@document), alert: 'Erro ao concluir tarefa.'
    end
  end

  def reopen
    if @task.reopen!
      redirect_to admin_document_document_tasks_path(@document), notice: 'Tarefa reaberta com sucesso.'
    else
      redirect_to admin_document_document_tasks_path(@document), alert: 'Erro ao reabrir tarefa.'
    end
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  def set_task
    @task = @document.document_tasks.find(params[:id])
  end

  def task_params
    params.require(:document_task).permit(:title, :description, :priority, :assigned_to_professional_id)
  end
end
