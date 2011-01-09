class AccountsController < InheritedResources::Base

  def destroy
    begin
      destroy!
    rescue Account::OrphanPostings
      flash.now[:failure] = 'Cannot delete account because it has dependants'
      render(:action => :show)
    end
  end

protected

  def collection
    @accounts ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 15)
  end
end
