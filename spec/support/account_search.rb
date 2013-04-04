class AccountSearch < Pilfer::Search

  search_on MockRelation

  searches :paid_amount, :business_name, :balance, :active

  coerces :active,      to: :boolean
  coerces :paid_amount, to: :integer

  def paid_amount_search
    results.where('amount > ?', paid_amount)
  end

  def business_name_search
    results.where(business_name: business_name)
  end

  def balance_search
    results.where("owed - amount > ?", balance)
  end

  def active_search
    results.where(active: active)
  end

end
