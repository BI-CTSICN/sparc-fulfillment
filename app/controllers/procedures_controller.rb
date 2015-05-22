class ProceduresController < ApplicationController

  before_action :find_procedure, only: [:edit, :update, :destroy]
  before_action :save_original_procedure_status, only: [:update]
  before_action :create_note_before_update, only: [:update]

  def create
    @appointment_id = params[:appointment_id]
    qty = params[:qty].to_i
    service = Service.find params[:service_id]
    @procedures = []
    qty.times do
      @procedures << Procedure.create(appointment_id: @appointment_id,
                                      service_id: service.id,
                                      service_name: service.name,
                                      billing_type: 'research_billing_qty',
                                      sparc_core_id: service.sparc_core_id,
                                      sparc_core_name: service.sparc_core_name)
    end
  end

  def edit
    @task = Task.new()
    if params[:partial].present?
      @note = @procedure.notes.new(kind: 'reason')
      render params[:partial]
    else
      render
    end
  end

  def update
    @procedure.update_attributes(@procedure_params)
  end

  def destroy
    @procedure.destroy
  end

  private

  def save_original_procedure_status
    @original_procedure_status = @procedure.status
  end

  def create_note_before_update
    if reset_status_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: 'Status reset',
                              kind: 'log')
    elsif incomplete_status_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: 'Status set to incomplete',
                              kind: 'log')
    elsif change_in_completed_date_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: "Completed date updated to #{procedure_params[:completed_date]} ",
                              kind: 'log')
    elsif complete_status_detected?
      @procedure.notes.create(identity: current_identity,
                              comment: 'Status set to complete',
                              kind: 'log')
    end
  end

  def change_in_completed_date_detected?
    if @procedure_params[:completed_date]
      Time.strptime(@procedure_params[:completed_date], "%m-%d-%Y") != @procedure.completed_date
    else
      return false
    end
  end

  def reset_status_detected?
    procedure_params[:status] == ""
  end

  def incomplete_status_detected?
    procedure_params[:status] == "incomplete"
  end

  def complete_status_detected?
    @original_procedure_status != "complete" && procedure_params[:status] == "complete"
  end

  def procedure_params
    @procedure_params = params.
                        require(:procedure).
                        permit(:status, :follow_up_date, :completed_date, :billing_type,
                                notes_attributes: [:comment, :kind, :identity_id, :reason],
                                tasks_attributes: [:assignee_id, :identity_id, :body, :due_at])
  end

  def find_procedure
    @procedure = Procedure.find params[:id]
  end
end
