# frozen_string_literal: true

require 'ostruct'

module Admin
  class GroupsController < BaseController
    before_action :set_group, only: %i[show edit update destroy]

    def index
      @groups = Group.all
      @pagy = OpenStruct.new(
        count: @groups.count,
        page: 1,
        items: 10,
        pages: 1,
        from: 1,
        to: @groups.count,
        prev: nil,
        next: nil,
        series: [1]
      )
    end

    def show; end

    def new
      @group = Group.new
      @permissions = Permission.ordered
    end

    def edit
      @permissions = Permission.ordered
    end

    def create
      @group = Group.new(group_params)

      if @group.save
        redirect_to admin_group_path(@group), notice: 'Grupo criado com sucesso.'
      else
        @permissions = Permission.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @group.update(group_params)
        redirect_to admin_group_path(@group), notice: 'Grupo atualizado com sucesso.'
      else
        @permissions = Permission.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @group.destroy
      redirect_to admin_groups_path, notice: 'Grupo excluído com sucesso.'
    end

    def search
      query = params[:q]
      groups = Group.where('name ILIKE ?', "%#{query}%")
                   .limit(10)
                   .map { |group| { id: group.id, name: group.name } }

      render json: groups
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :description, :is_admin, permission_ids: [])
    end
  end
end
