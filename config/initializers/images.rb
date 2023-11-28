# frozen_string_literal: true

# Favicons
FAVICONS_SRC = {
  "16px" => ENV.fetch("FAVICON_16PX_SRC", "favicons/16x16.png"),
  "32px" => ENV.fetch("FAVICON_32PX_SRC", "favicons/32x32.png"),
  "96px" => ENV.fetch("FAVICON_96PX_SRC", "favicons/96x96.png"),
  "apple_touch" => ENV.fetch("FAVICON_APPLE_TOUCH_152PX_SRC", "favicons/apple-touch-icon.png")
}.compact_blank.freeze

# Header logo
HEADER_LOGO_SRC = ENV.fetch("HEADER_LOGO_SRC", "republique-francaise-logo.svg")
HEADER_LOGO_ALT = ENV.fetch("HEADER_LOGO_ALT", "Délégation Générale Numérique (DGNum)")
HEADER_LOGO_WIDTH = ENV.fetch("HEADER_LOGO_WIDTH", "65")
HEADER_LOGO_HEIGHT = ENV.fetch("HEADER_LOGO_HEIGHT", "56")

# Mailer logos
MAILER_LOGO_SRC = ENV.fetch("MAILER_LOGO_SRC", "mailer/republique-francaise-logo.png")

# Default logo of a procedure
PROCEDURE_DEFAULT_LOGO_SRC = ENV.fetch("PROCEDURE_DEFAULT_LOGO_SRC", "republique-francaise-logo.svg")

# Logo in PDF export of a "Dossier"
DOSSIER_PDF_EXPORT_LOGO_SRC = ENV.fetch("DOSSIER_PDF_EXPORT_LOGO_SRC", "app/assets/images/header/logo-ds-wide.png")
