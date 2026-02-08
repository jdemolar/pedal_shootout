import './index.scss';
import { useState, useMemo } from 'react';

interface Pedal {
  id: number;
  manufacturer: string;
  model: string;
  effect_type: string | null;
  in_production: boolean;
  width_mm: number | null;
  depth_mm: number | null;
  height_mm: number | null;
  weight_grams: number | null;
  msrp_cents: number | null;
  product_page: string | null;
  instruction_manual: string | null;
  image_path: string | null;
  color_options: string | null;
  data_reliability: 'High' | 'Medium' | 'Low' | null;
  bypass_type: string | null;
  signal_type: string | null;
  circuit_type: string | null;
  mono_stereo: string | null;
  preset_count: number;
  midi_capable: boolean;
  has_tap_tempo: boolean;
  battery_capable: boolean;
  has_software_editor: boolean;
  power_voltage: string | null;
  power_current_ma: number | null;
}

// TODO: Replace with API call to SQLite backend
const DATA: Pedal[] = [{"id":68,"manufacturer":"1981 Inventions","model":"DRV","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":25000,"product_page":"https://1981inventions.com/items/drv","instruction_manual":null,"image_path":null,"color_options":"White No3, Black No3, Gold No3, Black/Pink No3, Hyperfade White, Hyperfade Black, Silver, Vaporwave, Silver (Professional)","data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":69,"manufacturer":"1981 Inventions","model":"LVL","effect_type":"Gain","in_production":true,"width_mm":62.0,"depth_mm":112.0,"height_mm":36.0,"weight_grams":null,"msrp_cents":22900,"product_page":"https://1981inventions.com/items/levelisimportant","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":45},
{"id":70,"manufacturer":"1981 Inventions","model":"MMHMM 20th Anniversary","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":25000,"product_page":"https://1981inventions.com/products/mmhmm-20th-anniversary","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V/18V DC","power_current_ma":null},
{"id":71,"manufacturer":"3 Leaf Audio","model":"Doom 2","effect_type":"Fuzz","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":33300,"product_page":"https://www.3leafaudio.com/shop/doom-775fk","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":7},
{"id":73,"manufacturer":"3 Leaf Audio","model":"Octabvre MK3.33","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":33300,"product_page":"https://www.3leafaudio.com/shop/octabvre","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":30},
{"id":72,"manufacturer":"3 Leaf Audio","model":"Proton MK4","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":33300,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9-18V DC","power_current_ma":null},
{"id":83,"manufacturer":"ADA Amps","model":"APP-1","effect_type":"Preamp","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":49995,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":87,"manufacturer":"ADA Amps","model":"Definition","effect_type":"Utility","in_production":false,"width_mm":114.3,"depth_mm":63.5,"height_mm":38.1,"weight_grams":null,"msrp_cents":19995,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9-18V DC","power_current_ma":null},
{"id":82,"manufacturer":"ADA Amps","model":"Final Phase Reissue","effect_type":"Other","in_production":false,"width_mm":171.5,"depth_mm":146.1,"height_mm":76.2,"weight_grams":null,"msrp_cents":24900,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"120V AC","power_current_ma":null},
{"id":81,"manufacturer":"ADA Amps","model":"Flanger Reissue","effect_type":"Other","in_production":false,"width_mm":171.5,"depth_mm":146.1,"height_mm":76.2,"weight_grams":null,"msrp_cents":57500,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"18V DC","power_current_ma":null},
{"id":84,"manufacturer":"ADA Amps","model":"GCS-2","effect_type":"Amp/Cab Sim","in_production":true,"width_mm":85.1,"depth_mm":106.7,"height_mm":45.7,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":85,"manufacturer":"ADA Amps","model":"GCS-3","effect_type":"Amp/Cab Sim","in_production":true,"width_mm":85.1,"depth_mm":106.7,"height_mm":45.7,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":200},
{"id":86,"manufacturer":"ADA Amps","model":"MP-1 Channel","effect_type":"Preamp","in_production":true,"width_mm":137.2,"depth_mm":127.0,"height_mm":45.7,"weight_grams":null,"msrp_cents":39995,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"12V DC","power_current_ma":800},
{"id":75,"manufacturer":"Abasi","model":"Micro-Aggressor","effect_type":"Compression","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24999,"product_page":"https://abasiconcepts.com/products/micro-aggressor","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":74,"manufacturer":"Abasi","model":"Pathos","effect_type":"Gain","in_production":true,"width_mm":63.5,"depth_mm":114.3,"height_mm":38.1,"weight_grams":null,"msrp_cents":18500,"product_page":"https://abasiconcepts.com/products/pathos","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":30},
{"id":79,"manufacturer":"Aclam","model":"Cinnamon Drive","effect_type":"Gain","in_production":true,"width_mm":137.2,"depth_mm":86.4,"height_mm":55.9,"weight_grams":null,"msrp_cents":29900,"product_page":"https://www.aclamguitars.com/store/cinnamon-drive.html","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":35},
{"id":76,"manufacturer":"Aclam","model":"Dr. Robert V3","effect_type":"Gain","in_production":false,"width_mm":137.2,"depth_mm":86.4,"height_mm":55.9,"weight_grams":null,"msrp_cents":32900,"product_page":"https://www.aclamguitars.com/store/dr-robert-v3.html","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":80,"manufacturer":"Aclam","model":"The Mocker","effect_type":"Fuzz","in_production":false,"width_mm":137.2,"depth_mm":86.4,"height_mm":55.9,"weight_grams":null,"msrp_cents":29900,"product_page":"https://www.aclamguitars.com/store/the-mocker.html","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":12},
{"id":78,"manufacturer":"Aclam","model":"The Windmiller Preamp","effect_type":"Preamp","in_production":true,"width_mm":137.2,"depth_mm":86.4,"height_mm":55.9,"weight_grams":null,"msrp_cents":31900,"product_page":"https://www.aclamguitars.com/store/the-windmiller.html","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":38},
{"id":77,"manufacturer":"Aclam","model":"The Woman Tone","effect_type":"Gain","in_production":true,"width_mm":137.2,"depth_mm":86.4,"height_mm":55.9,"weight_grams":null,"msrp_cents":33900,"product_page":"https://www.aclamguitars.com/store/the-woman-tone.html","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":40},
{"id":88,"manufacturer":"Adventure Audio","model":"Dream Reaper","effect_type":"Fuzz","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":92,"manufacturer":"Adventure Audio","model":"Glacial Zenith","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":16900,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":93,"manufacturer":"Adventure Audio","model":"Juniper","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Low","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":89,"manufacturer":"Adventure Audio","model":"Outer Rings","effect_type":"Other","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":90,"manufacturer":"Adventure Audio","model":"Power Couple","effect_type":"Utility","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":50},
{"id":91,"manufacturer":"Adventure Audio","model":"Whateverb V2","effect_type":"Reverb","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":250},
{"id":94,"manufacturer":"Aguilar","model":"Agro Bass Overdrive","effect_type":"Gain","in_production":true,"width_mm":57.2,"depth_mm":63.5,"height_mm":120.7,"weight_grams":null,"msrp_cents":22900,"product_page":"https://aguilaramp.com/products/agro-bass-overdrive-pedal","instruction_manual":"https://aguilar.korg-kid.com/manual/AGRO","image_path":null,"color_options":null,"data_reliability":"Low","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":97,"manufacturer":"Aguilar","model":"Chorusaurus Bass Chorus","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":22900,"product_page":"https://aguilaramp.com/en-int/products/chorusaurus-bass-chorus-pedal","instruction_manual":"https://aguilar.korg-kid.com/manual/CHORUSAURUS","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":98,"manufacturer":"Aguilar","model":"Chorusaurus Bass Chorus V2","effect_type":"Other","in_production":true,"width_mm":57.2,"depth_mm":63.5,"height_mm":120.7,"weight_grams":null,"msrp_cents":24900,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":104,"manufacturer":"Aguilar","model":"Filter Twin Dual Bass Envelope Filter","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":null,"instruction_manual":"https://aguilar.korg-kid.com/manual/FILTER_TWIN","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":95,"manufacturer":"Aguilar","model":"Fuzzistor Bass Fuzz","effect_type":"Fuzz","in_production":true,"width_mm":57.2,"depth_mm":63.5,"height_mm":120.7,"weight_grams":null,"msrp_cents":17900,"product_page":"https://aguilaramp.com/products/fuzzistor-bass-fuzz-pedal","instruction_manual":"https://aguilar.korg-kid.com/manual/FUZZISTOR","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":96,"manufacturer":"Aguilar","model":"Fuzzistor Bass Fuzz V2","effect_type":"Fuzz","in_production":true,"width_mm":57.2,"depth_mm":63.5,"height_mm":120.7,"weight_grams":null,"msrp_cents":19900,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":102,"manufacturer":"Aguilar","model":"Grape Phaser Bass Pedal","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":null,"instruction_manual":"https://aguilar.korg-kid.com/manual/GRAPE_PHASER","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":99,"manufacturer":"Aguilar","model":"Octamizer Analog Bass Octave","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":17900,"product_page":"https://aguilaramp.com/products/octamizer-analog-bass-octave-pedal","instruction_manual":"https://aguilar.korg-kid.com/manual/OCTAMIZER","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":100,"manufacturer":"Aguilar","model":"Octamizer V2 Analog Bass Octave","effect_type":"Other","in_production":true,"width_mm":57.2,"depth_mm":63.5,"height_mm":120.7,"weight_grams":null,"msrp_cents":19900,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":101,"manufacturer":"Aguilar","model":"Storm King Distortion Bass Pedal","effect_type":"Fuzz","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":16900,"product_page":"https://aguilaramp.com/products/storm-king-distortion-bass-pedal","instruction_manual":"https://aguilar.korg-kid.com/manual/STORM_KING","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":103,"manufacturer":"Aguilar","model":"TLC Bass Compressor","effect_type":"Compression","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":22900,"product_page":null,"instruction_manual":"https://aguilar.korg-kid.com/manual/TLC_COMP","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":null,"power_current_ma":null},
{"id":45,"manufacturer":"JHS Pedals","model":"3 Series Distortion","effect_type":"Gain","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-distortion","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-distortion-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":44,"manufacturer":"JHS Pedals","model":"3 Series Flanger","effect_type":"Other","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-flanger","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-flanger-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":43,"manufacturer":"JHS Pedals","model":"3 Series Fuzz","effect_type":"Fuzz","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-fuzz","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-fuzz-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":46,"manufacturer":"JHS Pedals","model":"3 Series Harmonic Tremolo","effect_type":"Other","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-harmonic-tremolo","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-harmonic-tremolo-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":39,"manufacturer":"JHS Pedals","model":"3 Series Octave Reverb","effect_type":"Reverb","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-octave-reverb","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-octave-reverb-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":36,"manufacturer":"JHS Pedals","model":"3 Series Oil Can Delay","effect_type":"Delay","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-oil-can-delay","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-oil-can-delay-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":42,"manufacturer":"JHS Pedals","model":"3 Series Overdrive","effect_type":"Gain","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-overdrive","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-overdrive-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":40,"manufacturer":"JHS Pedals","model":"3 Series Reverb","effect_type":"Reverb","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-reverb","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-reverb-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":37,"manufacturer":"JHS Pedals","model":"3 Series Rotary Chorus","effect_type":"Other","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-rotary-chorus","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-rotary-chorus-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":41,"manufacturer":"JHS Pedals","model":"3 Series Screamer","effect_type":"Gain","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-screamer","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-screamer-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":38,"manufacturer":"JHS Pedals","model":"3 Series Tape Delay","effect_type":"Delay","in_production":true,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":9900,"product_page":"https://jhspedals.info/products/3-series-tape-delay","instruction_manual":"https://manuals.plus/jhs/pedals-3-series-tape-delay-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":70},
{"id":3,"manufacturer":"JHS Pedals","model":"424 Gain Stage","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/424-gain-stage","instruction_manual":"https://manuals.plus/jhs/pedals-424-gain-stage-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":17,"manufacturer":"JHS Pedals","model":"AT+","effect_type":"Gain","in_production":true,"width_mm":55.9,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":21900,"product_page":"https://jhspedals.info/products/at","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":15},
{"id":29,"manufacturer":"JHS Pedals","model":"Active A/B/Y","effect_type":"Utility","in_production":false,"width_mm":112.3,"depth_mm":60.5,"height_mm":31.0,"weight_grams":null,"msrp_cents":13000,"product_page":"https://jhspedals.info/products/active-aby","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":47},
{"id":18,"manufacturer":"JHS Pedals","model":"Angry Charlie V3","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/angry-charlie-v3","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":35,"manufacturer":"JHS Pedals","model":"Artificial Blonde","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/artificial-blonde","instruction_manual":"https://manuals.plus/jhs/pedals-artificial-blonde-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":59,"manufacturer":"JHS Pedals","model":"Bat Sim","effect_type":"Utility","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/bat-sim","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":55,"manufacturer":"JHS Pedals","model":"Big Muffuletta","effect_type":"Fuzz","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/big-muffuletta","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":14,"manufacturer":"JHS Pedals","model":"Bonsai","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/bonsai","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":20},
{"id":23,"manufacturer":"JHS Pedals","model":"Charlie Brown V4","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/charlie-brown-v4","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":27,"manufacturer":"JHS Pedals","model":"Cheese Ball","effect_type":"Fuzz","in_production":true,"width_mm":66.0,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":17900,"product_page":"https://jhspedals.info/products/cheese-ball","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":9},
{"id":24,"manufacturer":"JHS Pedals","model":"Clover","effect_type":"Preamp","in_production":true,"width_mm":66.0,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/clover","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":7,"manufacturer":"JHS Pedals","model":"Colour Box 10","effect_type":"Preamp","in_production":true,"width_mm":144.8,"depth_mm":95.3,"height_mm":47.0,"weight_grams":null,"msrp_cents":44900,"product_page":"https://jhspedals.info/products/colour-box-10","instruction_manual":"https://manuals.plus/jhs/pedals-colour-box-10-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":193},
{"id":6,"manufacturer":"JHS Pedals","model":"Colour Box V2","effect_type":"Preamp","in_production":true,"width_mm":144.8,"depth_mm":95.3,"height_mm":47.0,"weight_grams":null,"msrp_cents":44900,"product_page":"https://jhspedals.info/products/colour-box-v2","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":193},
{"id":34,"manufacturer":"JHS Pedals","model":"Crayon","effect_type":"Gain","in_production":true,"width_mm":66.0,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/crayon","instruction_manual":"https://manuals.plus/jhs/pedals-crayon-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":50,"manufacturer":"JHS Pedals","model":"Double Barrel V4","effect_type":"Multi Effects","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":29900,"product_page":"https://jhspedals.info/products/double-barrel-v4","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":47,"manufacturer":"JHS Pedals","model":"EHX by JHS - Big Muff 2","effect_type":"Fuzz","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/big-muff-2","instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":18},
{"id":20,"manufacturer":"JHS Pedals","model":"Emperor V2","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":21900,"product_page":"https://jhspedals.info/products/emperor-v2","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":11,"manufacturer":"JHS Pedals","model":"Flight Delay","effect_type":"Delay","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/flight-delay","instruction_manual":"https://manuals.plus/jhs/pedals-flight-delay-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":57,"manufacturer":"JHS Pedals","model":"Germanium Boost","effect_type":"Utility","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/germanium-boost","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":8,"manufacturer":"JHS Pedals","model":"Hard Drive","effect_type":"Gain","in_production":true,"width_mm":66.0,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/hard-drive","instruction_manual":"https://manuals.plus/jhs/pedals-hard-drive-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":78},
{"id":25,"manufacturer":"JHS Pedals","model":"Haunting Mids","effect_type":"Utility","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":14900,"product_page":"https://jhspedals.info/products/haunting-mids","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":10,"manufacturer":"JHS Pedals","model":"Kilt 10","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/kilt-10","instruction_manual":"https://manuals.plus/jhs/pedals-kilt-10-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":9,"manufacturer":"JHS Pedals","model":"Kilt V2","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/kilt-v2","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":22,"manufacturer":"JHS Pedals","model":"Kodiak","effect_type":"Other","in_production":true,"width_mm":66.0,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":21900,"product_page":"https://jhspedals.info/products/kodiak","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":10},
{"id":56,"manufacturer":"JHS Pedals","model":"Lizard Queen","effect_type":"Fuzz","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/lizard-queen","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":28,"manufacturer":"JHS Pedals","model":"Milkman","effect_type":"Delay","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":17900,"product_page":"https://jhspedals.info/products/milkman","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":26,"manufacturer":"JHS Pedals","model":"Moonshine V2","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/moonshine-v2","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":81},
{"id":1,"manufacturer":"JHS Pedals","model":"Morning Glory Clean","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":17900,"product_page":"https://jhspedals.info/products/morning-glory-clean","instruction_manual":"https://manuals.plus/jhs/pedals-morning-glory-clean-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":2,"manufacturer":"JHS Pedals","model":"Morning Glory V4","effect_type":"Gain","in_production":true,"width_mm":55.9,"depth_mm":121.9,"height_mm":40.6,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/morning-glory-v4","instruction_manual":"https://manuals.plus/jhs/pedals-morning-glory-v4-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":43},
{"id":15,"manufacturer":"JHS Pedals","model":"Muffuletta","effect_type":"Fuzz","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/muffuletta","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":5,"manufacturer":"JHS Pedals","model":"Notadümblë","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":11900,"product_page":"https://jhspedals.info/products/notadumble","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":4,"manufacturer":"JHS Pedals","model":"Notaklön","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":11900,"product_page":"https://jhspedals.info/products/notaklon","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":"Standard, Pink, Splatter","data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":52,"manufacturer":"JHS Pedals","model":"Notaklön Blackout","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/notaklon-blackout","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":33,"manufacturer":"JHS Pedals","model":"Overdrive Preamp","effect_type":"Gain","in_production":false,"width_mm":119.4,"depth_mm":94.0,"height_mm":42.2,"weight_grams":null,"msrp_cents":17900,"product_page":"https://jhspedals.info/products/overdrive-preamp","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":51},
{"id":19,"manufacturer":"JHS Pedals","model":"PG-14","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/pg-14","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":81},
{"id":13,"manufacturer":"JHS Pedals","model":"PackRat","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":24900,"product_page":"https://jhspedals.info/products/packrat","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":"Standard, White","data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":62,"manufacturer":"JHS Pedals","model":"Panther Cub","effect_type":"Delay","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/panther-cub","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":30,"manufacturer":"JHS Pedals","model":"Prestige","effect_type":"Utility","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":12900,"product_page":"https://jhspedals.info/products/prestige","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":16,"manufacturer":"JHS Pedals","model":"Pulp N Peel V4","effect_type":"Compression","in_production":true,"width_mm":66.0,"depth_mm":121.9,"height_mm":38.1,"weight_grams":null,"msrp_cents":22900,"product_page":"https://jhspedals.info/products/pulp-n-peel-v4","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":65,"manufacturer":"JHS Pedals","model":"ROSS Chorus","effect_type":"Other","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":63,"manufacturer":"JHS Pedals","model":"ROSS Compressor","effect_type":"Compression","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":64,"manufacturer":"JHS Pedals","model":"ROSS Distortion","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":67,"manufacturer":"JHS Pedals","model":"ROSS Fuzz","effect_type":"Fuzz","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":66,"manufacturer":"JHS Pedals","model":"ROSS Phaser","effect_type":"Other","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":null,"instruction_manual":null,"image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":54,"manufacturer":"JHS Pedals","model":"Spring Tank","effect_type":"Reverb","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/spring-tank","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":48,"manufacturer":"JHS Pedals","model":"Summing Amp","effect_type":"Utility","in_production":true,"width_mm":91.4,"depth_mm":38.1,"height_mm":25.4,"weight_grams":null,"msrp_cents":8500,"product_page":"https://jhspedals.info/products/summing-amp","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":19},
{"id":53,"manufacturer":"JHS Pedals","model":"SuperBolt V2","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/superbolt-v2","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC or 18V DC","power_current_ma":100},
{"id":51,"manufacturer":"JHS Pedals","model":"Sweet Tea V3","effect_type":"Multi Effects","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":34500,"product_page":"https://jhspedals.info/products/sweet-tea-v3","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":49,"manufacturer":"JHS Pedals","model":"Switchback","effect_type":"Utility","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":12000,"product_page":"https://jhspedals.info/products/switchback","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":31},
{"id":60,"manufacturer":"JHS Pedals","model":"The Bulb","effect_type":"Gain","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/the-bulb","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":12,"manufacturer":"JHS Pedals","model":"The Violet","effect_type":"Gain","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":19900,"product_page":"https://jhspedals.info/products/the-violet","instruction_manual":"https://manuals.plus/jhs/pedals-the-violet-manual","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":32,"manufacturer":"JHS Pedals","model":"Tidewater","effect_type":"Other","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":13500,"product_page":"https://jhspedals.info/products/tidewater","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":21,"manufacturer":"JHS Pedals","model":"Unicorn V2","effect_type":"Other","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":21900,"product_page":"https://jhspedals.info/products/unicorn-v2","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100},
{"id":61,"manufacturer":"JHS Pedals","model":"VCR (Space Commander)","effect_type":"Multi Effects","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/vcr-space-commander","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":80},
{"id":58,"manufacturer":"JHS Pedals","model":"Voice Tech","effect_type":"Utility","in_production":false,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":null,"product_page":"https://jhspedals.info/products/voice-tech","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"Medium","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":null},
{"id":31,"manufacturer":"JHS Pedals","model":"Whitey Tighty","effect_type":"Compression","in_production":true,"width_mm":null,"depth_mm":null,"height_mm":null,"weight_grams":null,"msrp_cents":13500,"product_page":"https://jhspedals.info/products/whitey-tighty","instruction_manual":"https://www.jhspedals.com/web/content/1254?unique=2d2386ed1fdc615577de819199151ad1ef84c033&download=true","image_path":null,"color_options":null,"data_reliability":"High","bypass_type":null,"signal_type":null,"circuit_type":null,"mono_stereo":"Mono","preset_count":0,"midi_capable":false,"has_tap_tempo":false,"battery_capable":false,"has_software_editor":false,"power_voltage":"9V DC","power_current_ma":100}];

type SortColumn = 'manufacturer' | 'model' | 'effect_type' | 'in_production' | 'msrp_cents' | 'data_reliability';
type SortDirection = 1 | -1;

const EFFECT_TYPES = ['All', ...Array.from(new Set(DATA.map(d => d.effect_type).filter((t): t is string => t !== null))).sort()];
const STATUSES = ['All', 'In Production', 'Discontinued'] as const;
const RELIABILITIES = ['All', 'High', 'Medium', 'Low'] as const;

interface ColumnDef {
  key: SortColumn;
  label: string;
  width: number;
  align?: 'left' | 'center' | 'right';
}

const COLUMNS: ColumnDef[] = [
  { key: 'manufacturer', label: 'Manufacturer', width: 160 },
  { key: 'model', label: 'Model', width: 200 },
  { key: 'effect_type', label: 'Type', width: 120, align: 'center' },
  { key: 'in_production', label: 'Status', width: 80, align: 'center' },
  { key: 'msrp_cents', label: 'MSRP', width: 80, align: 'right' },
  { key: 'manufacturer' as SortColumn, label: 'Dimensions', width: 160, align: 'center' },
  { key: 'manufacturer' as SortColumn, label: 'Power', width: 100, align: 'center' },
  { key: 'data_reliability', label: 'Reliability', width: 80, align: 'center' },
];

const Pedals = () => {
  const [search, setSearch] = useState('');
  const [effectTypeFilter, setEffectTypeFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');
  const [reliabilityFilter, setReliabilityFilter] = useState('All');
  const [sortCol, setSortCol] = useState<SortColumn>('manufacturer');
  const [sortDir, setSortDir] = useState<SortDirection>(1);
  const [expandedId, setExpandedId] = useState<number | null>(null);

  const filtered = useMemo(() => {
    let result = DATA;

    if (search) {
      const s = search.toLowerCase();
      result = result.filter(p => p.manufacturer.toLowerCase().includes(s) || p.model.toLowerCase().includes(s));
    }

    if (effectTypeFilter !== 'All') {
      result = result.filter(p => p.effect_type === effectTypeFilter);
    }

    if (statusFilter !== 'All') {
      const inProd = statusFilter === 'In Production';
      result = result.filter(p => p.in_production === inProd);
    }

    if (reliabilityFilter !== 'All') {
      result = result.filter(p => p.data_reliability === reliabilityFilter);
    }

    return [...result].sort((a, b) => {
      const va = a[sortCol];
      const vb = b[sortCol];

      if (va == null && vb == null) return 0;
      if (va == null) return 1;
      if (vb == null) return -1;

      if (typeof va === 'boolean' && typeof vb === 'boolean') {
        return (Number(va) - Number(vb)) * sortDir;
      }

      if (typeof va === 'number' && typeof vb === 'number') {
        return (va - vb) * sortDir;
      }

      if (typeof va === 'string' && typeof vb === 'string') {
        return va.localeCompare(vb) * sortDir;
      }

      return 0;
    });
  }, [search, effectTypeFilter, statusFilter, reliabilityFilter, sortCol, sortDir]);

  const handleSort = (col: SortColumn) => {
    if (sortCol === col) {
      setSortDir(d => (d === 1 ? -1 : 1));
    } else {
      setSortCol(col);
      setSortDir(1);
    }
  };

  const totalPedals = DATA.length;
  const inProductionCount = DATA.filter(p => p.in_production).length;
  const uniqueEffectTypes = new Set(DATA.map(p => p.effect_type).filter(t => t !== null)).size;

  const formatMsrp = (cents: number | null): string => {
    if (cents == null) return '\u2014';
    return `$${(cents / 100).toFixed(2)}`;
  };

  const formatDimensions = (w: number | null, d: number | null, h: number | null): string => {
    if (w != null && d != null && h != null) return `${w} \u00d7 ${d} \u00d7 ${h} mm`;
    return '\u2014';
  };

  const formatPower = (voltage: string | null, current: number | null): string => {
    if (voltage && current) return `${voltage} / ${current}mA`;
    if (voltage) return voltage;
    if (current) return `${current}mA`;
    return '\u2014';
  };

  return (
    <div className="pedals">
      <div className="pedals__header">
        <div className="pedals__title-group">
          <h1 className="pedals__title">Pedal Database</h1>
          <span className="pedals__stats">
            {totalPedals} pedals \u00b7 {inProductionCount} in production \u00b7 {uniqueEffectTypes} effect types
          </span>
        </div>
      </div>

      <div className="pedals__filters">
        <div className="pedals__search-wrapper">
          <span className="pedals__search-icon">&#x2315;</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search pedals..."
            className="pedals__search"
          />
        </div>

        <select
          value={effectTypeFilter}
          onChange={e => setEffectTypeFilter(e.target.value)}
          className="pedals__select"
        >
          {EFFECT_TYPES.map(t => (
            <option key={t} value={t}>
              {t === 'All' ? 'Type: All' : t}
            </option>
          ))}
        </select>

        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value)}
          className="pedals__select"
        >
          {STATUSES.map(s => (
            <option key={s} value={s}>
              {s === 'All' ? 'Status: All' : s}
            </option>
          ))}
        </select>

        <select
          value={reliabilityFilter}
          onChange={e => setReliabilityFilter(e.target.value)}
          className="pedals__select"
        >
          {RELIABILITIES.map(r => (
            <option key={r} value={r}>
              {r === 'All' ? 'Reliability: All' : r}
            </option>
          ))}
        </select>

        <span className="pedals__filter-count">
          {filtered.length} pedal{filtered.length !== 1 ? 's' : ''} shown
        </span>
      </div>

      <div className="pedals__table-wrapper">
        <table className="pedals__table">
          <thead>
            <tr>
              {COLUMNS.map((col, ci) => (
                <th
                  key={ci}
                  onClick={() => col.label !== 'Dimensions' && col.label !== 'Power' ? handleSort(col.key) : undefined}
                  className="pedals__th"
                  style={{ width: col.width, textAlign: col.align || 'left', cursor: col.label === 'Dimensions' || col.label === 'Power' ? 'default' : 'pointer' }}
                >
                  {col.label}
                  {col.label !== 'Dimensions' && col.label !== 'Power' && (
                    <span className={`pedals__sort-icon ${sortCol === col.key ? 'active' : ''}`}>
                      {sortCol === col.key ? (sortDir === 1 ? '\u25b2' : '\u25bc') : '\u21c5'}
                    </span>
                  )}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((p, i) => {
              const isExpanded = expandedId === p.id;

              return (
                <>
                  <tr
                    key={p.id}
                    onClick={() => setExpandedId(isExpanded ? null : p.id)}
                    className={`pedals__row ${isExpanded ? 'expanded' : ''} ${i % 2 === 0 ? 'even' : 'odd'}`}
                  >
                    <td className="pedals__td pedals__td--name">{p.manufacturer}</td>
                    <td className="pedals__td pedals__td--model">{p.model}</td>
                    <td className="pedals__td pedals__td--effect-type" style={{ textAlign: 'center' }}>
                      {p.effect_type ? (
                        <span className={`effect-badge effect-badge--${p.effect_type.toLowerCase().replace(/[\s/]+/g, '-')}`}>
                          {p.effect_type}
                        </span>
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                    <td className="pedals__td pedals__td--status" style={{ textAlign: 'center' }}>
                      <span className={`status-badge status-badge--${p.in_production ? 'in-production' : 'discontinued'}`}>
                        {p.in_production ? 'Active' : 'Disc.'}
                      </span>
                    </td>
                    <td className="pedals__td pedals__td--msrp" style={{ textAlign: 'right' }}>
                      {formatMsrp(p.msrp_cents) === '\u2014' ? (
                        <span className="null-value">\u2014</span>
                      ) : (
                        formatMsrp(p.msrp_cents)
                      )}
                    </td>
                    <td className="pedals__td pedals__td--dimensions" style={{ textAlign: 'center' }}>
                      {formatDimensions(p.width_mm, p.depth_mm, p.height_mm) === '\u2014' ? (
                        <span className="null-value">\u2014</span>
                      ) : (
                        formatDimensions(p.width_mm, p.depth_mm, p.height_mm)
                      )}
                    </td>
                    <td className="pedals__td pedals__td--power" style={{ textAlign: 'center' }}>
                      {formatPower(p.power_voltage, p.power_current_ma) === '\u2014' ? (
                        <span className="null-value">\u2014</span>
                      ) : (
                        formatPower(p.power_voltage, p.power_current_ma)
                      )}
                    </td>
                    <td className="pedals__td pedals__td--reliability" style={{ textAlign: 'center' }}>
                      {p.data_reliability ? (
                        <span className={`reliability-badge reliability-badge--${p.data_reliability.toLowerCase()}`}>
                          {p.data_reliability}
                        </span>
                      ) : (
                        <span className="null-value">\u2014</span>
                      )}
                    </td>
                  </tr>
                  {isExpanded && (
                    <tr key={`exp-${p.id}`} className="pedals__expanded-row">
                      <td colSpan={8} className="pedals__expanded-cell">
                        <div className="pedals__expanded-content">
                          {p.bypass_type != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Bypass Type</div>
                              <div className="pedals__detail-value">{p.bypass_type}</div>
                            </div>
                          )}
                          {p.signal_type != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Signal Type</div>
                              <div className="pedals__detail-value">{p.signal_type}</div>
                            </div>
                          )}
                          {p.circuit_type != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Circuit Type</div>
                              <div className="pedals__detail-value">{p.circuit_type}</div>
                            </div>
                          )}
                          {p.mono_stereo != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Mono/Stereo</div>
                              <div className="pedals__detail-value">{p.mono_stereo}</div>
                            </div>
                          )}
                          <div className="pedals__detail">
                            <div className="pedals__detail-label">MIDI Capable</div>
                            <div className="pedals__detail-value"><span className={p.midi_capable ? 'bool-yes' : 'bool-no'}>{p.midi_capable ? 'Yes' : 'No'}</span></div>
                          </div>
                          {p.preset_count > 0 && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Presets</div>
                              <div className="pedals__detail-value highlight">{p.preset_count}</div>
                            </div>
                          )}
                          <div className="pedals__detail">
                            <div className="pedals__detail-label">Tap Tempo</div>
                            <div className="pedals__detail-value"><span className={p.has_tap_tempo ? 'bool-yes' : 'bool-no'}>{p.has_tap_tempo ? 'Yes' : 'No'}</span></div>
                          </div>
                          <div className="pedals__detail">
                            <div className="pedals__detail-label">Battery</div>
                            <div className="pedals__detail-value"><span className={p.battery_capable ? 'bool-yes' : 'bool-no'}>{p.battery_capable ? 'Yes' : 'No'}</span></div>
                          </div>
                          <div className="pedals__detail">
                            <div className="pedals__detail-label">Software Editor</div>
                            <div className="pedals__detail-value"><span className={p.has_software_editor ? 'bool-yes' : 'bool-no'}>{p.has_software_editor ? 'Yes' : 'No'}</span></div>
                          </div>
                          {p.color_options != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Color Options</div>
                              <div className="pedals__detail-value">{p.color_options}</div>
                            </div>
                          )}
                          {p.product_page != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Product Page</div>
                              <div className="pedals__detail-value">
                                <a
                                  href={p.product_page}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {p.product_page}
                                </a>
                              </div>
                            </div>
                          )}
                          {p.instruction_manual != null && (
                            <div className="pedals__detail">
                              <div className="pedals__detail-label">Instruction Manual</div>
                              <div className="pedals__detail-value">
                                <a
                                  href={p.instruction_manual}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  onClick={e => e.stopPropagation()}
                                  className="detail-link"
                                >
                                  {p.instruction_manual}
                                </a>
                              </div>
                            </div>
                          )}
                        </div>
                      </td>
                    </tr>
                  )}
                </>
              );
            })}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="pedals__empty">No pedals match your filters.</div>
        )}
      </div>
    </div>
  );
};

export default Pedals;
