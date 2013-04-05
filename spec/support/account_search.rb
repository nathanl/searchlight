class AccountSearch < Pilfer::Search

  search_on MockModel

  searches :paid_amount, :business_name, :balance, :active

  def paid_amount_search
    search.where('amount > ?', paid_amount)
  end

  def business_name_search
    search.where(business_name: business_name)
  end

  def balance_search
    search.where("owed - amount > ?", balance)
  end

  def active_search
    search.where(active: active?)
  end

end
