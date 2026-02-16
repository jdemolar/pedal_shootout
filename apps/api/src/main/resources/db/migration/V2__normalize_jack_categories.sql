-- Normalize jack category values to lowercase convention
-- (previously stored as title-case composite values like 'Audio Input', 'Power Input')
UPDATE jacks SET category = 'audio' WHERE category IN ('Audio Input', 'Audio Output');
UPDATE jacks SET category = 'power' WHERE category IN ('Power Input', 'Power Output');
UPDATE jacks SET category = 'midi' WHERE category IN ('MIDI In', 'MIDI Out');
UPDATE jacks SET category = 'aux' WHERE category = 'Aux';
UPDATE jacks SET category = 'expression' WHERE category = 'Expression';
UPDATE jacks SET category = 'usb' WHERE category = 'USB';

-- Normalize direction values to lowercase
UPDATE jacks SET direction = LOWER(direction) WHERE direction IN ('Input', 'Output', 'Bidirectional');
