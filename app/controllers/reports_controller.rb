class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new
    @title = @report_type.titleize
    @organizations = current_identity.fulfillment_organizations_with_protocols
    @grouped_options = InvoiceReportGroupedOptions.new(@organizations).collect_grouped_options
  end

  def create
    @document = Document.new(title: reports_params[:title].humanize, report_type: @report_type)
    @report = @report_type.classify.constantize.new(reports_params)

    @errors = @report.errors
    
    if @report.valid?
      @reports_params = reports_params
      @documentable.documents.push @document
      ReportJob.perform_later(@document, reports_params)
    end
  end

  def update_dropdown
    org_ids = params[:org_ids]

    @protocols = []
    if org_ids.length > 1 
      org_ids.each do |org_id|
        @protocols << find_protocols(org_id)
      end
    else
      @protocols << find_protocols(org_ids)
    end
    @protocols = @protocols.flatten
  end

  private

  def find_protocols(org_ids)
    Protocol.
      joins(:sub_service_request).
      where(sub_service_requests: { organization_id: org_ids })
  end

  def find_documentable
    if params[:documentable_id].present? && params[:documentable_type].present?
      @documentable = params[:documentable_type].constantize.find params[:documentable_id]
    else
      @documentable = current_identity
    end
  end

  def find_report_type
    @report_type = reports_params[:report_type]
  end

  def reports_params
    params.require(:report_type) # raises error if report_type not present

    params.permit(:format,
              :utf8,
              :report_type,
              :title,
              :start_date,
              :end_date,
              :time_zone,
              :protocol_id,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_ids => []).merge(identity_id: current_identity.id)
  end
end
