class AccountSearch < Searchlight::Search

  search_on MockModel

  searches :paid_amount, :business_name, :balance, :active

  def search_paid_amount
    search.where('amount > ?', paid_amount)
  end

  def search_business_name
    search.where(business_name: business_name)
  end

  def search_balance
    search.where("owed - amount > ?", balance)
  end

  def search_active
    search.where(active: active?)
  end

end
