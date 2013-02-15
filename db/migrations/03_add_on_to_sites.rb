Sequel.migration do
  change do
    add_column :sites, :on, TrueClass, :default => true
    self[:sites].update(:on => true)
  end
end
