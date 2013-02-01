Sequel.migration do
  change do
    create_table(:sites) do
      primary_key :id
      String :host
      Integer :port
    end
  end
end
