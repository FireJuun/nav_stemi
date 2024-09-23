/// [didGetAspirin] and [isCathLabNotified] uses this logic:
///
/// null -> no value has been recorded. This occurs when the model
/// is first loaded or if the data is intentionally removed
///
/// false -> specifically answered as negative. An example would be if the
/// patient is allergic to aspirin and thus cannot receive it
///
/// true -> answered as positive. self explanatory
///
/// Because checklist values use bool? handling differently,
/// this method translates between the two
///
class BoolDataToChecklistDTO {
  const BoolDataToChecklistDTO();

  bool? convertBoolDataToChecklist({required bool? boolData}) =>
      switch (boolData) {
        /// data set to true. returns as (+) true on checklist
        true => true,

        /// data set to false. returns as (-) null on checklist
        false => null,

        /// data isn't set (null). returns as ( ) false on checklist
        null => false,
      };

  bool? convertChecklistToBoolData({required bool? checklist}) =>
      switch (checklist) {
        /// (+) true on checklist. returns as true
        true => true,

        /// ( ) false on checklist. returns as null
        false => null,

        /// (-) null on checklist. returns as false
        null => false,
      };
}
