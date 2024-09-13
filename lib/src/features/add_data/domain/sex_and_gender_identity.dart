/// Follows USCDI v4 guidelines on patient demographics.
/// https://www.healthit.gov/isa/uscdi-data-class/patient-demographicsinformation#uscdi-v4
///
/// ... as well as the FHIR v4 standard using SexAtBirth
/// spec: https://github.com/fhir-fli/fhir_r4/blob/8a7c6651c14ba7cf1ed5b623ab79c93d860db3c7/lib/src/fhir/resource_types/base/individuals/individuals.dart#L883
///
library;

enum SexAtBirth { male, female, other, unknown }

/// This may later be updated to include GenderIdentity, if desired
// enum GenderIdentity {}
