Sequel.migration do
  change do
    create_table(:requests) do
      primary_key :id
      String :path
      String :host
      Integer :port
      DateTime :created_at
    end
  end
end
