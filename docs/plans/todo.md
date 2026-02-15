# TODO

 1. Add type-specific views:

- [x] Manufacturers
- [x] Products
- [x] Pedals
- [x] Power Supplies
- [x] Pedalboards
- [x] MIDI Controllers
- [x] Utilities
- [ ] Plugs

2. Add use-case views:

- [ ] /board-planner    → Combines pedalboards + pedals + power supplies + plugs
- [ ] /power-budget     → Pedals with power requirements vs supply capacity
- [ ] /midi-planner     → Controllers + MIDI-capable pedals

3. Build the "smart" features:

- [ ] **Power budget calculator** - Sum pedal power *current* ma values vs supply capacity
- [ ] **Signal path validator** - Flag mono/stereo mismatches, impedance issues
- [ ] **MIDI routing helper** - Match controller outputs to pedal MIDI needs

4. Add images to views so that user can see the product within the details view (in expanded row panels)

5. Create a way for users to put multiple products into a "cart" for the purpose of product comparison and compatibility analysis, generating a shopping list, and moving to pedal arrangement

6. Create pedalboard layout planning (similar to pedalplayground.com)

- System for displaying images on a canvas where scale of all products is relative to each other

7. Add product instructions (especially MIDI controllers)

- Add instruction manuals for popular midi controllers to provide a guide on pedalboard programming. Although there may be multiple ways of accomplishing various goals with a controller, having a guide can at least recommend solutions when given a specific problem.
- This will be where real value could come into effect. Having AI equipped with instruction manuals could enable users to have a plain-language interface for programming their midi controllers for their desired workflow with their specific pedals.

8. Move app into cloud infrastructure

Data Maintenance Notes (ongoing)
- Regularly verify and update reliability ratings as new sources emerge
- When crowd-sourcing begins, all user-submitted data starts as "Low" until verified
- Cross-reference specifications across multiple sources when possible
- Flag conflicts between sources for manual review
