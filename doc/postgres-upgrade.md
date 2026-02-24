# PostgreSQL 14 upgrade playbook

The service currently runs on PostgreSQL 13, which is end-of-life. PostgreSQL
14 or later must be adopted using the steps below.

## 1. Compatibility checklist

* Code search confirmed that none of the PostgreSQL 14 breaking changes apply:
  only the `pg_trgm`, `pgcrypto`, `plpgsql`, and `uuid-ossp` extensions are
  enabled (`db/schema.rb:18-21`), and there are no custom operators or raw SQL
  using the affected features.
* Terraform config pins every environment to Flexible Server 13. Azure cannot
  perform in-place major upgrades, so new servers are required.
* Target versions and support windows:
  * PostgreSQL 14 – EOL 12 Nov 2026.
  * PostgreSQL 15 – EOL 11 Nov 2027.
  * PostgreSQL 16 – EOL 9 Nov 2028.

## 2. Fast dev upgrade (portal)

1. Confirm a recent automatic backup exists (Azure’s point-in-time restore
   feature is enabled by default).
2. In the Azure portal, run the “major version upgrade” option or provision a
   new Flexible Server 14 instance for dev experimentation.
3. If the upgrade fails, restore from backup:
   1. Portal → **Azure Database for PostgreSQL flexible servers** → select the
      dev server.
   2. **Backups** → **Restore**.
   3. Pick a restore point, supply a new server name. Restores always create a
      fresh server, so the portal shows the full monthly price for that server
      until the old one is removed.
   4. After the restore finishes, update the dev `DATABASE_URL` to the new
      hostname or delete/rename servers as needed.

## 3. Terraform-first workflow

Once experimentation is complete, use Terraform for every environment:

1. Update the relevant `tfvars` to set `postgresql_server_version = "14"`
   (or `"15"`, `"16"` if leapfrogging).
2. `terraform apply` to create the new server(s) in the correct VNet/subnet,
   including a read replica if the environment requires one.
3. Recreate required extensions and run `ALTER EXTENSION ... UPDATE`.
4. Load data:
   * Small datasets: take a `pg_dump` from the 13 server and restore into the
     new server.
   * Large datasets: establish logical replication from the existing 13 primary
     into the new 14 primary until fully synced.
5. Update Key Vault/secret store entries containing `DATABASE_URL` and redeploy
   applications so they point at the new server.
6. Leave the 13 server in read-only standby until satisfied, then remove it
   from Terraform state and delete the resource to stop billing.

## 4. Production and staging (with read replica)

1. Build a new 14 primary **and** a new 14 read replica via Terraform (Azure
   cannot promote a 13 replica into a 14 primary).
2. Migrate data (dump/restore or logical replication) into the new primary and
   confirm replication to the new secondary.
3. Run the Rails test suite and smoke tests against staging wired to the new
   servers.
4. Schedule a maintenance window for production, freeze writes, perform a final
   sync, update secrets/connection strings, deploy, and monitor.
5. After the cutover succeeds, delete the 13 primary/replica pair.

These instructions keep every environment on a supported PostgreSQL release,
document the Azure restore behaviour (restores always create a new server), and
ensure the upgrade is reproducible through Terraform.
