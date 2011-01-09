class JournalsController < InheritedResources::Base
  belongs_to :account

protected

  def collection
    @journals ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 15)
  end
end
