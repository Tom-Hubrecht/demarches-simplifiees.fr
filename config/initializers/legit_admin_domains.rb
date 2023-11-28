domains = ["gouv.fr", "sante.fr", "cnafmail.fr", "cnamts.fr", "cci.fr", "caf.fr", "msa.fr", "assurance-maladie.fr", "dgnum.eu", "normalesup.org", "ens.fr", "ens.psl.eu", "normalesup.eu"]
LEGIT_ADMIN_DOMAINS = ENV["LEGIT_ADMIN_DOMAINS"]&.split(';') || domains
