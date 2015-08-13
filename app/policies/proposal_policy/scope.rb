class ProposalPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # returns the entire list of Proposals that are visible to the user
    def resolve
      if @user.admin?
        @scope.all
      elsif @user.client_admin?
        self.for_client_admin
      else
        @scope.where(Query::Proposals.which_involve(@user))
      end
    end

    protected

    def for_client_admin
      @scope.where(
        Query::Proposals.for_client_slug(@user.client_slug).or(
          Query::Proposals.which_involve(@user)
        )
      )
    end
  end
end