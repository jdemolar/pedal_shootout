import React, { useState, useMemo } from "react";

const DATA = [{"id":1,"name":"1981 Inventions","country":"USA","founded":"2018","status":"Active","specialty":"Guitar effects pedals and accessories","website":"1981inventions.com","notes":null,"pedal_count":3},
{"id":2,"name":"3 Leaf Audio","country":"USA","founded":"2008","status":"Active","specialty":"Guitar effects pedals and accessories","website":"3leafaudio.com","notes":null,"pedal_count":3},
{"id":5,"name":"ADA Amps","country":"USA","founded":"1978","status":"Active","specialty":"Guitar effects pedals and amplifiers","website":"adaamps.com","notes":null,"pedal_count":0},
{"id":14,"name":"AMT Electronics","country":"Russia","founded":"1987","status":"Active","specialty":"Guitar effects pedals, amplifiers, preamplifiers, cabinets","website":"amtelectronics.com","notes":null,"pedal_count":0},
{"id":20,"name":"ARC Effects","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals and custom projects","website":"arc-effects.com","notes":null,"pedal_count":0},
{"id":24,"name":"ART","country":"Canada/USA","founded":"1984","status":"Active","specialty":"Professional audio equipment","website":"artproaudio.com","notes":null,"pedal_count":0},
{"id":3,"name":"Abasi","country":"USA","founded":"2017","status":"Active","specialty":"Guitars, guitar effects pedals and accessories","website":"abasiconcepts.com","notes":null,"pedal_count":2},
{"id":4,"name":"Aclam","country":"Spain","founded":"2010","status":"Active","specialty":"Guitar effects pedals, pedalboards, guitars and accessories","website":"aclamguitars.com","notes":null,"pedal_count":5},
{"id":6,"name":"Adventure Audio","country":"USA","founded":"2014","status":"Active","specialty":"Guitar effects pedals and Eurorack modules","website":"adventurepedals.com","notes":null,"pedal_count":0},
{"id":7,"name":"Aguilar","country":"USA","founded":"1995","status":"Active","specialty":"Guitar effects pedals and bass guitar amplifiers","website":"aguilaramp.com","notes":null,"pedal_count":0},
{"id":8,"name":"Aleks K Production","country":"Canada","founded":"2012","status":"Active","specialty":"Guitar effects pedals, electric guitars and pickups","website":"alekskproduction.com","notes":null,"pedal_count":0},
{"id":9,"name":"Alesis","country":"USA","founded":"1984","status":"Active","specialty":"Multi-effects and music production equipment","website":"alesis.com","notes":null,"pedal_count":0},
{"id":10,"name":"Alexander Pedals","country":"USA","founded":"2015","status":"Active","specialty":"Guitar effects pedals","website":"alexanderpedals.com","notes":null,"pedal_count":0},
{"id":11,"name":"Ammoon","country":"China","founded":"2016","status":"Active","specialty":"Guitar effects pedals, amplifiers, musical instruments, pro audio","website":"ammoon.com","notes":null,"pedal_count":0},
{"id":12,"name":"Ampeg","country":"USA","founded":"1946","status":"Active","specialty":"Bass guitar amplifiers","website":"ampeg.com","notes":"Owned by Yamaha","pedal_count":0},
{"id":13,"name":"Amptweaker","country":"USA","founded":"2009","status":"Active","specialty":"Guitar effects pedals","website":"amptweaker.com","notes":null,"pedal_count":0},
{"id":15,"name":"Analog Alien","country":"USA","founded":"2009","status":"Active","specialty":"Guitar effects pedals","website":"analogalien.com","notes":null,"pedal_count":0},
{"id":16,"name":"Analog.Man","country":"USA","founded":"2000","status":"Active","specialty":"Guitar effects pedals","website":"buyanalogman.com","notes":null,"pedal_count":0},
{"id":17,"name":"Anarchy Audio","country":"Australia","founded":"2011","status":"Active","specialty":"Guitar effects pedals and modifications","website":null,"notes":null,"pedal_count":0},
{"id":18,"name":"Anasounds","country":"France","founded":"2013","status":"Active","specialty":"Guitar effects pedals and DIY kits","website":"anasounds.com","notes":null,"pedal_count":0},
{"id":19,"name":"Animals Pedal","country":"Japan","founded":"2015","status":"Active","specialty":"Guitar effects pedals and picks","website":"animalspedal.jp","notes":null,"pedal_count":0},
{"id":21,"name":"Area 51","country":"USA","founded":"2002","status":"Active","specialty":"Guitar effects pedals, modification kits, custom work","website":"area51tubeaudiodesigns.com","notes":null,"pedal_count":0},
{"id":22,"name":"Arion","country":"Sri Lanka","founded":"1973","status":"Active","specialty":"Guitar effects pedals, tuners and amplifiers","website":"arion-ukc.co.jp","notes":"Originally Japan","pedal_count":0},
{"id":23,"name":"Aroma","country":"China","founded":"2008","status":"Active","specialty":"Guitar effects pedals, amplifiers, electronic drums","website":"aromamusic.cn","notes":null,"pedal_count":0},
{"id":25,"name":"Artec","country":"South Korea","founded":"1996","status":"Active","specialty":"Guitar effects pedals, pickups, amplifiers","website":"artecsound.com","notes":null,"pedal_count":0},
{"id":26,"name":"Ashdown","country":"United Kingdom","founded":"1997","status":"Active","specialty":"Bass amplifiers","website":"ashdownmusic.com","notes":null,"pedal_count":0},
{"id":27,"name":"Audio Sprockets","country":"USA","founded":"2017","status":"Active","specialty":"Guitar effects pedals, pickups, amplifiers","website":"audiosprockets.com","notes":null,"pedal_count":0},
{"id":28,"name":"Authentic Hendrix","country":"USA","founded":"1972","status":"Active","specialty":"Guitar effects pedals","website":"jimdunlop.com","notes":"Dunlop subsidiary","pedal_count":0},
{"id":29,"name":"Azor","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals, power supplies","website":"azorpedal.com","notes":null,"pedal_count":0},
{"id":33,"name":"BBE","country":"USA","founded":"1985","status":"Active","specialty":"Guitar effects pedals, software, DI units, preamplifiers","website":"bbesound.com","notes":null,"pedal_count":0},
{"id":42,"name":"BJFE","country":"Sweden","founded":"2000","status":"Defunct","specialty":"Guitar effects pedals","website":"bjornjuhl.com","notes":null,"pedal_count":0},
{"id":53,"name":"BYOC","country":"USA","founded":"2004","status":"Active","specialty":"DIY guitar effects pedals, amplifiers, parts, tools","website":"buildyourownclone.com","notes":"Build Your Own Clone","pedal_count":0},
{"id":30,"name":"Bananana Effects","country":"Japan","founded":"2014","status":"Active","specialty":"Guitar effects pedals","website":"banananaeffects.com","notes":null,"pedal_count":0},
{"id":31,"name":"Barber Electronics","country":"USA","founded":"1997","status":"Active","specialty":"Guitar effects pedals","website":"barberelectronics.com","notes":null,"pedal_count":0},
{"id":32,"name":"Basic Audio","country":"USA","founded":"2002","status":"Active","specialty":"Guitar pedals","website":"basicaudio.net","notes":null,"pedal_count":0},
{"id":34,"name":"BearFoot FX","country":"USA","founded":"2011","status":"Active","specialty":"Guitar effects pedals","website":"bearfootfx.com","notes":null,"pedal_count":0},
{"id":35,"name":"BecosFX","country":"Romania","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":"becosfx.com","notes":null,"pedal_count":0},
{"id":36,"name":"Beetronics FX","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":"beetronicsfx.com","notes":null,"pedal_count":0},
{"id":37,"name":"Behringer","country":"Germany","founded":"1989","status":"Active","specialty":"Prosumer audio equipment","website":"behringer.com","notes":null,"pedal_count":0},
{"id":38,"name":"Benson Amps","country":"USA","founded":"2016","status":"Active","specialty":"Guitar amplifiers, pedals and accessories","website":"bensonamps.com","notes":null,"pedal_count":0},
{"id":39,"name":"Big Ear Pedals","country":"USA","founded":"2018","status":"Active","specialty":"Guitar effects pedals","website":"bigearpedals.com","notes":null,"pedal_count":0},
{"id":40,"name":"Big Joe Stomp Box Company","country":"USA","founded":"2011","status":"Active","specialty":"Guitar effects pedals","website":"bigjoestompbox.com","notes":null,"pedal_count":0},
{"id":41,"name":"Biyang","country":"Netherlands","founded":"2000","status":"Active","specialty":"Guitar effects pedals, amplifiers, wireless systems","website":"biyang.nl","notes":null,"pedal_count":0},
{"id":43,"name":"Black Arts Toneworks","country":"USA","founded":"2012","status":"Active","specialty":"Guitar effects pedals","website":"blackartstoneworks.com","notes":null,"pedal_count":0},
{"id":44,"name":"Black Cat Pedals","country":"USA","founded":"1993","status":"Active","specialty":"Guitar effects pedals and Eurorack modules","website":"blackcatpedals.com","notes":null,"pedal_count":0},
{"id":45,"name":"Black Country Customs","country":"United Kingdom","founded":"1967","status":"Active","specialty":"Guitar effects pedals, amplifiers and cabinets","website":"laney.co.uk","notes":"Laney brand","pedal_count":0},
{"id":46,"name":"Blackhawk Amplifiers","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":47,"name":"Blackout Effectors","country":"USA","founded":"2008","status":"Active","specialty":"Guitar effects pedals","website":"blackouteffectors.com","notes":null,"pedal_count":0},
{"id":48,"name":"BluGuitar","country":"Germany","founded":"2014","status":"Active","specialty":"Guitar effects pedals, guitars, amplifiers, cabinets","website":"bluguitar.com","notes":null,"pedal_count":0},
{"id":49,"name":"Bogner Amplification","country":"USA","founded":"1989","status":"Active","specialty":"Guitar effects pedals, amplifiers, cabinets, pickups","website":null,"notes":null,"pedal_count":0},
{"id":50,"name":"Bondi Effects","country":"Australia","founded":"2013","status":"Active","specialty":"Guitar effects pedals","website":"bondieffects.com","notes":null,"pedal_count":0},
{"id":51,"name":"Boss","country":"Japan","founded":"1973","status":"Active","specialty":"Guitar effects pedals, amplifiers and wireless systems","website":"boss.info","notes":"Roland subsidiary","pedal_count":0},
{"id":52,"name":"Buffalo FX","country":"France","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":"buffalo-fx.com","notes":null,"pedal_count":0},
{"id":64,"name":"CMAT Mods","country":"USA","founded":"2016","status":"Active","specialty":"Guitar effects pedals","website":"cmatmods.com","notes":null,"pedal_count":0},
{"id":65,"name":"CNZ","country":"USA","founded":"2016","status":"Active","specialty":"Guitar effects pedals, percussion, stringed instruments","website":"cnzaudio.com","notes":null,"pedal_count":0},
{"id":54,"name":"Caline","country":"China","founded":"2011","status":"Active","specialty":"Guitar effects pedals, amplifiers, power supplies","website":"calinemusic.com","notes":null,"pedal_count":0},
{"id":55,"name":"Carl Martin","country":"Denmark","founded":"1990","status":"Active","specialty":"Guitar effects pedals, amplifiers and cabinets","website":"carlmartin.com","notes":null,"pedal_count":0},
{"id":56,"name":"Caroline Guitar Company","country":"USA","founded":"2010","status":"Active","specialty":"Guitar effects pedals","website":"carolineguitar.com","notes":null,"pedal_count":0},
{"id":57,"name":"Carvin Corporation","country":"USA","founded":"1946","status":"Active","specialty":"Guitar effects pedals, amplifiers, cabinets, loudspeakers","website":"carvinaudio.com","notes":null,"pedal_count":0},
{"id":58,"name":"Catalinbread Effects","country":"USA","founded":"2003","status":"Active","specialty":"Guitar effects pedals","website":"catalinbread.com","notes":null,"pedal_count":0},
{"id":59,"name":"Center Street Electronics","country":"USA","founded":null,"status":"Unknown","specialty":"Guitar effects pedals and modifications","website":null,"notes":null,"pedal_count":0},
{"id":60,"name":"Chandler Limited","country":"USA","founded":"1999","status":"Active","specialty":"Professional audio hardware","website":"chandlerlimited.com","notes":null,"pedal_count":0},
{"id":61,"name":"Chase Bliss Audio","country":"USA","founded":"2013","status":"Active","specialty":"Guitar effects pedals and utility","website":"chasebliss.com","notes":null,"pedal_count":0},
{"id":62,"name":"Chase Tone","country":"USA","founded":"2012","status":"Active","specialty":"Guitar effects pedals and amplifiers","website":"chasetone.com","notes":null,"pedal_count":0},
{"id":63,"name":"Cicognani Engineering","country":"Italy","founded":null,"status":"Active","specialty":"Guitar effects pedals, amplifiers and accessories","website":"cicognani.eu","notes":null,"pedal_count":0},
{"id":66,"name":"Coda Effects","country":"France","founded":"2015","status":"Active","specialty":"Guitar pedals and printed circuit boards","website":"coda-effects.com","notes":null,"pedal_count":0},
{"id":67,"name":"Coolmusic","country":"China","founded":"2007","status":"Active","specialty":"Electronics drums, amplifiers, guitar effects pedals","website":"coolmusic-tech.com","notes":null,"pedal_count":0},
{"id":68,"name":"Cooper FX","country":"USA","founded":"2015","status":"Defunct","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":69,"name":"CopperSound","country":"USA","founded":"2014","status":"Active","specialty":"Guitar effects pedals","website":"coppersoundpedals.com","notes":null,"pedal_count":0},
{"id":70,"name":"Costalab","country":"Italy","founded":"2011","status":"Active","specialty":"Guitar effects pedals, pedalboards, amplifiers","website":"costalab.com","notes":null,"pedal_count":0},
{"id":71,"name":"Crazy Tube Circuits","country":"Greece","founded":"2011","status":"Active","specialty":"Guitar effects pedals","website":"crazytubecircuits.com","notes":null,"pedal_count":0},
{"id":72,"name":"Creative Audio Labs","country":"USA","founded":"2003","status":"Active","specialty":"Guitar effects pedals, outboard gear, components","website":"creationaudiolabs.com","notes":null,"pedal_count":0},
{"id":73,"name":"Crowther Audio","country":"New Zealand","founded":"1976","status":"Defunct","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":74,"name":"Cry Baby","country":"USA","founded":"1972","status":"Active","specialty":"Guitar effects pedals","website":"jimdunlop.com","notes":"Dunlop subsidiary","pedal_count":0},
{"id":75,"name":"Cusack Music","country":"USA","founded":"1972","status":"Active","specialty":"Guitar effects pedals","website":"cusackmusic.com","notes":null,"pedal_count":0},
{"id":76,"name":"Custom Tones","country":"USA","founded":"2013","status":"Active","specialty":"Guitar effects pedals, preamp, power amplifiers","website":"customtonesinc.com","notes":null,"pedal_count":0},
{"id":77,"name":"D'Addario","country":"USA","founded":"1974","status":"Active","specialty":"Guitars, musical instruments and music accessories","website":"daddario.com","notes":null,"pedal_count":0},
{"id":96,"name":"DLS Effect","country":"USA","founded":"1999","status":"Active","specialty":"Guitar effects pedals","website":"dlseffects.com","notes":null,"pedal_count":0},
{"id":97,"name":"DMB Pedals","country":"USA","founded":"2007","status":"Defunct","specialty":"Guitar effects pedals","website":null,"notes":"Defunct 2016","pedal_count":0},
{"id":98,"name":"DOD","country":"USA","founded":"1973","status":"Active","specialty":"Guitar effects pedals","website":"digitech.com/dod","notes":"DigiTech subsidiary","pedal_count":0},
{"id":78,"name":"DanDrive Pedal Solution","country":"Germany","founded":"2017","status":"Defunct","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":79,"name":"Dandy Job","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals, amplifiers, parts","website":"dandyjob.com","notes":null,"pedal_count":0},
{"id":80,"name":"Danelectro","country":"USA","founded":"1947","status":"Active","specialty":"Guitar effects pedals, guitars and accessories","website":"danelectro.com","notes":null,"pedal_count":0},
{"id":81,"name":"Daredevil Pedal","country":"USA","founded":"2012","status":"Active","specialty":"Guitar effects pedals","website":"daredevilpedals.com","notes":null,"pedal_count":0},
{"id":82,"name":"Darkglass Electronics","country":"Finland","founded":"2009","status":"Active","specialty":"Bass guitar effects pedals, amplifiers","website":"darkglass.com","notes":null,"pedal_count":0},
{"id":83,"name":"Dawner Prince Electronics","country":"Croatia","founded":"2009","status":"Active","specialty":"Guitar effects pedals","website":"dawnerprince.com","notes":null,"pedal_count":0},
{"id":84,"name":"Deadbeat Sound","country":"USA","founded":"2017","status":"Active","specialty":"Guitar effects pedals and sample packs","website":"deadbeatsound.com","notes":null,"pedal_count":0},
{"id":85,"name":"Death By Audio","country":"USA","founded":"2002","status":"Active","specialty":"Guitar effects pedals","website":"deathbyaudio.com","notes":null,"pedal_count":0},
{"id":86,"name":"Decibelics","country":"Spain","founded":"2010","status":"Active","specialty":"Guitar effects pedals and modifications","website":"decibelics.com","notes":null,"pedal_count":0},
{"id":87,"name":"Deep Space Devices","country":"USA","founded":"2018","status":"Active","specialty":"Guitar effects pedals and synthesizers","website":"deepspacedevices.com","notes":null,"pedal_count":0},
{"id":88,"name":"Deep Trip","country":"Brazil","founded":"2007","status":"Active","specialty":"Guitar effects pedals","website":"deeptripland.com","notes":null,"pedal_count":0},
{"id":89,"name":"Defects FX","country":"Czech Republic","founded":"2019","status":"Active","specialty":"Guitar effects pedals","website":"defectsfxpedals.cz","notes":null,"pedal_count":0},
{"id":90,"name":"Demeter","country":"USA","founded":"1980","status":"Active","specialty":"Guitar amplifiers and pro audio","website":"demeteramps.com","notes":null,"pedal_count":0},
{"id":91,"name":"Demon Pedals","country":"Germany","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":"demonpedals.com","notes":null,"pedal_count":0},
{"id":92,"name":"Devi Ever : FX","country":"USA","founded":"2003","status":"Active","specialty":"Guitar effects pedals","website":"deviever.net","notes":null,"pedal_count":0},
{"id":93,"name":"Diamond","country":"Canada","founded":"2004","status":"Active","specialty":"Guitar effects pedals","website":"diamondpedals.com","notes":null,"pedal_count":0},
{"id":94,"name":"Diezel Amplification","country":"Germany","founded":"1992","status":"Active","specialty":"Guitar effects pedals, amplifiers and cabinets","website":"diezelamplification.com","notes":null,"pedal_count":0},
{"id":95,"name":"DigiTech","country":"USA","founded":"1984","status":"Active","specialty":"Guitar effects pedals","website":"digitech.com","notes":"Harman/Samsung","pedal_count":0},
{"id":100,"name":"Donner","country":"China","founded":"2012","status":"Active","specialty":"Guitar effects pedals, guitars, keyboards, drums","website":"donnerdeal.com","notes":null,"pedal_count":0},
{"id":99,"name":"Dophix","country":"Italy","founded":"2015","status":"Active","specialty":"Guitar effects pedals","website":"dophix.it","notes":null,"pedal_count":0},
{"id":101,"name":"Dr. J","country":"China","founded":"2006","status":"Active","specialty":"Guitar effects pedals, amplifiers","website":"joyoaudio.co.uk","notes":"Joyo subsidiary","pedal_count":0},
{"id":102,"name":"Dr. No Effects","country":"Netherlands","founded":"2014","status":"Active","specialty":"Guitar effects pedals and guitar accessories","website":"shop.drno-effects.com","notes":null,"pedal_count":0},
{"id":103,"name":"Dr. Scientist","country":"Canada","founded":"2005","status":"Active","specialty":"Guitar effects pedals","website":"drscientist.ca","notes":null,"pedal_count":0},
{"id":104,"name":"Dreadbox","country":"Greece","founded":"2012","status":"Active","specialty":"Guitar effects pedals, synthesizers, chromatic modules","website":"dreadbox-fx.com","notes":null,"pedal_count":0},
{"id":105,"name":"Drolo FX","country":"Belgium","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":"drolofx.com","notes":null,"pedal_count":0},
{"id":106,"name":"DryBell","country":"Croatia","founded":"1996","status":"Active","specialty":"Guitar effects pedals","website":"drybell.com","notes":null,"pedal_count":0},
{"id":107,"name":"Duesenberg","country":"Germany","founded":"1986","status":"Active","specialty":"Guitars, bass guitars, amplifiers, effects pedals","website":"duesenberg.de","notes":null,"pedal_count":0},
{"id":108,"name":"Dunlop","country":"USA","founded":"1972","status":"Active","specialty":"Guitar effects pedals, electronics, picks, strings","website":"jimdunlop.com","notes":null,"pedal_count":0},
{"id":109,"name":"Durham Electronics","country":"USA","founded":"2000","status":"Active","specialty":"Guitar effects pedals, amplifiers, repairs","website":"durhamelectronics.com","notes":null,"pedal_count":0},
{"id":110,"name":"Dusky Electronics","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals, amplifiers, cabinets","website":"duskyamp.com","notes":null,"pedal_count":0},
{"id":111,"name":"Dwarfcraft Devices","country":"USA","founded":"2007","status":"Active","specialty":"Guitar effects pedals","website":"dwarfcraft.com","notes":null,"pedal_count":0},
{"id":113,"name":"EBS","country":"Sweden","founded":"1988","status":"Active","specialty":"Guitar effects pedals, amplifiers, cabinets","website":"ebssweden.com","notes":null,"pedal_count":0},
{"id":112,"name":"EarthQuaker Devices","country":"USA","founded":"2004","status":"Active","specialty":"Guitar effects pedals, eurorack modules","website":"earthquakerdevices.com","notes":null,"pedal_count":0},
{"id":114,"name":"Effectivity Wonder","country":"Spain","founded":"2013","status":"Active","specialty":"Guitar effects pedals, synthesizers, outboard hardware","website":"effectivywonder.com","notes":null,"pedal_count":0},
{"id":115,"name":"Egnater","country":"USA","founded":"1975","status":"Active","specialty":"Guitar amplifiers","website":"egnateramps.com","notes":null,"pedal_count":0},
{"id":116,"name":"Electro-Harmonix","country":"USA","founded":"1968","status":"Active","specialty":"Effects pedals and audio components","website":"ehx.com","notes":null,"pedal_count":0},
{"id":117,"name":"Empress Effects","country":"Canada","founded":"2005","status":"Active","specialty":"Guitar effects pedals","website":"empresseffects.com","notes":null,"pedal_count":0},
{"id":118,"name":"Eventide","country":"USA","founded":"1971","status":"Active","specialty":"Professional audio effects","website":"eventideaudio.com","notes":null,"pedal_count":0},
{"id":119,"name":"Fairfield Circuitry","country":"Canada","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":120,"name":"Fender","country":"USA","founded":"1946","status":"Active","specialty":"Guitars, amplifiers, effects pedals","website":"fender.com","notes":null,"pedal_count":0},
{"id":121,"name":"Fishman","country":"USA","founded":"1981","status":"Active","specialty":"Guitar pickups and amplification","website":null,"notes":null,"pedal_count":0},
{"id":122,"name":"Foxgear","country":"Italy","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":123,"name":"Foxrox Electronics","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":124,"name":"Free The Tone","country":"Japan","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":125,"name":"Friedman Amplification","country":"USA","founded":null,"status":"Active","specialty":"Guitar amplifiers and pedals","website":null,"notes":null,"pedal_count":0},
{"id":126,"name":"Fulltone","country":"USA","founded":"1991","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":128,"name":"GFI System","country":"Indonesia","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":127,"name":"Gamechanger Audio","country":"Latvia","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":129,"name":"Greer Amplification","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals and amplifiers","website":null,"notes":null,"pedal_count":0},
{"id":130,"name":"Ground Control Audio","country":"Canada","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":131,"name":"Guyatone","country":"Japan","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":132,"name":"Hamstead Soundworks","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":133,"name":"Hartke","country":"USA","founded":null,"status":"Active","specialty":"Bass amplification","website":null,"notes":null,"pedal_count":0},
{"id":134,"name":"Henretta Engineering","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":135,"name":"Hologram Electronics","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":136,"name":"Horizon Devices","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":137,"name":"Hotone","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals and amplifiers","website":null,"notes":null,"pedal_count":0},
{"id":138,"name":"Hudson Electronics","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":139,"name":"Hughes & Kettner","country":"Germany","founded":null,"status":"Active","specialty":"Guitar amplifiers","website":null,"notes":null,"pedal_count":0},
{"id":141,"name":"IK Multimedia","country":"Italy","founded":null,"status":"Active","specialty":"Audio interfaces and effects","website":null,"notes":null,"pedal_count":0},
{"id":140,"name":"Ibanez","country":"Japan","founded":"1957","status":"Active","specialty":"Guitars, bass guitars, effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":146,"name":"J Rockett Audio Designs","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":143,"name":"JAM Pedals","country":"Greece","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":144,"name":"JHS Pedals","country":"USA","founded":"2007","status":"Active","specialty":"Guitar effects pedals","website":"jhspedals.info","notes":"Already catalogued","pedal_count":67},
{"id":142,"name":"Jackson Audio","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":145,"name":"Joyo Audio","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals and amplifiers","website":null,"notes":null,"pedal_count":0},
{"id":148,"name":"KHDK Electronics","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":150,"name":"KMA Machines","country":"Germany","founded":"2013","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":147,"name":"Keeley Electronics","country":"USA","founded":"2001","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":149,"name":"Klon","country":"USA","founded":null,"status":"Discontinued","specialty":"Guitar effects pedals","website":null,"notes":"Legendary Centaur","pedal_count":0},
{"id":151,"name":"Korg","country":"Japan","founded":"1962","status":"Active","specialty":"Synthesizers, effects pedals, tuners","website":null,"notes":null,"pedal_count":0},
{"id":155,"name":"LR Baggs","country":"USA","founded":null,"status":"Active","specialty":"Acoustic guitar pickups and preamps","website":null,"notes":null,"pedal_count":0},
{"id":152,"name":"Lehle","country":"Germany","founded":null,"status":"Active","specialty":"Guitar switchers and effects","website":null,"notes":null,"pedal_count":0},
{"id":153,"name":"Line 6","country":"USA","founded":"1996","status":"Active","specialty":"Guitar effects and modeling","website":null,"notes":null,"pedal_count":0},
{"id":154,"name":"Lovepedal","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":162,"name":"MI Audio","country":"Australia","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":169,"name":"MXR","country":"USA","founded":"1972","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":"Dunlop subsidiary","pedal_count":0},
{"id":156,"name":"Mad Professor","country":"Finland","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":157,"name":"Malekko","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":158,"name":"Markbass","country":"Italy","founded":null,"status":"Active","specialty":"Bass amplification","website":null,"notes":null,"pedal_count":0},
{"id":159,"name":"Maxon","country":"Japan","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":160,"name":"Meris","country":"USA","founded":"2014","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":161,"name":"Mesa/Boogie","country":"USA","founded":"1969","status":"Active","specialty":"Guitar amplifiers and effects","website":null,"notes":null,"pedal_count":0},
{"id":163,"name":"Mission Engineering","country":"USA","founded":"2009","status":"Active","specialty":"Expression pedals and controllers","website":null,"notes":null,"pedal_count":0},
{"id":164,"name":"Mojo Hand FX","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":165,"name":"Mooer","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals (micro series)","website":null,"notes":null,"pedal_count":0},
{"id":166,"name":"Moog Music","country":"USA","founded":"1953","status":"Active","specialty":"Synthesizers and effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":167,"name":"Morley","country":"USA","founded":null,"status":"Active","specialty":"Wah and volume pedals","website":null,"notes":null,"pedal_count":0},
{"id":168,"name":"Mr. Black","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":170,"name":"Mythos Pedals","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":172,"name":"Neunaber","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":171,"name":"Neural DSP","country":"Finland","founded":null,"status":"Active","specialty":"Guitar effects pedals and plugins","website":null,"notes":null,"pedal_count":0},
{"id":173,"name":"Nobels","country":"Germany","founded":"1985","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":174,"name":"Nux","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals and amplifiers","website":null,"notes":null,"pedal_count":0},
{"id":175,"name":"Old Blood Noise Endeavors","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":176,"name":"OneControl","country":"Japan","founded":null,"status":"Active","specialty":"Guitar effects pedals (compact)","website":null,"notes":null,"pedal_count":0},
{"id":177,"name":"Orange","country":"United Kingdom","founded":"1968","status":"Active","specialty":"Guitar amplifiers and effects","website":null,"notes":null,"pedal_count":0},
{"id":178,"name":"Origin Effects","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":179,"name":"Pettyjohn Electronics","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":180,"name":"Pigtronix","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":181,"name":"Pladask Elektrisk","country":"Norway","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":182,"name":"Positive Grid","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects and modeling","website":null,"notes":null,"pedal_count":0},
{"id":183,"name":"ProCo","country":"USA","founded":"1974","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":"RAT pedal","pedal_count":0},
{"id":188,"name":"REVV Amplification","country":"Canada","founded":null,"status":"Active","specialty":"Guitar amplifiers and pedals","website":null,"notes":null,"pedal_count":0},
{"id":184,"name":"Radial Engineering","country":"Canada","founded":null,"status":"Active","specialty":"Direct boxes and guitar effects","website":null,"notes":null,"pedal_count":0},
{"id":185,"name":"Rainger FX","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":186,"name":"Red Panda Lab","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":187,"name":"Red Witch Pedals","country":"New Zealand","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":189,"name":"Rivera Amplification","country":"USA","founded":null,"status":"Active","specialty":"Guitar amplifiers","website":null,"notes":null,"pedal_count":0},
{"id":190,"name":"Rocktron","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects and accessories","website":null,"notes":null,"pedal_count":0},
{"id":191,"name":"Roger Mayer","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":"Hendrix connection","pedal_count":0},
{"id":192,"name":"Roland","country":"Japan","founded":"1972","status":"Active","specialty":"Synthesizers, effects, amplifiers","website":null,"notes":"Boss parent","pedal_count":0},
{"id":193,"name":"Rothwell","country":"United Kingdom","founded":null,"status":"Active","specialty":"Audio attenuators and pedals","website":null,"notes":null,"pedal_count":0},
{"id":194,"name":"Seymour Duncan","country":"USA","founded":"1976","status":"Active","specialty":"Guitar pickups and effects","website":null,"notes":null,"pedal_count":0},
{"id":195,"name":"Shift Line","country":"Russia","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":196,"name":"Singular Sound","country":"USA","founded":null,"status":"Active","specialty":"Looping and drum pedals","website":null,"notes":null,"pedal_count":0},
{"id":197,"name":"Skreddy Pedals","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":198,"name":"Smallsound/Bigsound","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":199,"name":"SolidGoldFX","country":"Canada","founded":"2006","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":200,"name":"Sonic Research","country":"USA","founded":null,"status":"Active","specialty":"Guitar tuners","website":null,"notes":null,"pedal_count":0},
{"id":201,"name":"Sonicake","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":202,"name":"Source Audio","country":"USA","founded":"2006","status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":203,"name":"Spaceman Effects","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":204,"name":"Stone Deaf FX","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":205,"name":"Strymon","country":"USA","founded":null,"status":"Active","specialty":"High-end digital guitar effects","website":null,"notes":null,"pedal_count":0},
{"id":206,"name":"Subdecay Effects","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":207,"name":"Suhr","country":"USA","founded":null,"status":"Active","specialty":"Guitars and effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":208,"name":"T-Rex Engineering","country":"Denmark","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":209,"name":"TC Electronic","country":"Denmark","founded":"1976","status":"Active","specialty":"Guitar effects and audio equipment","website":null,"notes":null,"pedal_count":0},
{"id":210,"name":"Tech 21","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects and amplification","website":null,"notes":"SansAmp","pedal_count":0},
{"id":211,"name":"ThorpyFX","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":212,"name":"Tone City","country":"Canada","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":213,"name":"Truetone","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects and power supplies","website":null,"notes":null,"pedal_count":0},
{"id":214,"name":"Two Notes","country":"France","founded":null,"status":"Active","specialty":"Cabinet simulators and effects","website":null,"notes":null,"pedal_count":0},
{"id":215,"name":"Union Tube & Transistor","country":"Canada","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":216,"name":"Valeton","country":"China","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":217,"name":"Vemuram","country":"Japan","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":218,"name":"Vertex Effects","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":219,"name":"Victory Amps","country":"United Kingdom","founded":null,"status":"Active","specialty":"Guitar amplifiers and pedals","website":null,"notes":null,"pedal_count":0},
{"id":220,"name":"Voodoo Lab","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects and power supplies","website":null,"notes":null,"pedal_count":0},
{"id":221,"name":"Vox","country":"United Kingdom","founded":"1957","status":"Active","specialty":"Guitar amplifiers and effects","website":null,"notes":null,"pedal_count":0},
{"id":226,"name":"WMD Devices","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":222,"name":"Walrus Audio","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":223,"name":"Wampler Pedals","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":224,"name":"Way Huge","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":"Dunlop subsidiary","pedal_count":0},
{"id":225,"name":"Whirlwind","country":"USA","founded":null,"status":"Active","specialty":"Audio cables and effects","website":null,"notes":null,"pedal_count":0},
{"id":227,"name":"Wren And Cuff","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":228,"name":"Xotic Effects","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals","website":null,"notes":null,"pedal_count":0},
{"id":229,"name":"Xvive Audio","country":"USA","founded":null,"status":"Active","specialty":"Guitar effects pedals and wireless","website":null,"notes":null,"pedal_count":0},
{"id":230,"name":"Yamaha","country":"Japan","founded":"1887","status":"Active","specialty":"Musical instruments, audio equipment","website":null,"notes":null,"pedal_count":0},
{"id":232,"name":"ZVex","country":"USA","founded":null,"status":"Active","specialty":"Handpainted boutique effects","website":null,"notes":null,"pedal_count":0},
{"id":231,"name":"Zoom","country":"Japan","founded":null,"status":"Active","specialty":"Multi-effects pedals","website":null,"notes":null,"pedal_count":0}];

const STATUS_STYLE = {
  Active:       { bg:"#1a3322", text:"#5ccc88" },
  Defunct:      { bg:"#2a1818", text:"#cc6060" },
  Discontinued: { bg:"#2a2518", text:"#c8a840" },
  Unknown:      { bg:"#222222", text:"#888888" }
};

const COUNTRIES = ["All",...new Set(DATA.map(d=>d.country).filter(Boolean).sort())];
const STATUSES = ["All","Active","Defunct","Discontinued","Unknown"];

const COUNTRY_STATS = {};
DATA.forEach(m => {
  const c = m.country || "Unknown";
  if(!COUNTRY_STATS[c]) COUNTRY_STATS[c]=0;
  COUNTRY_STATS[c]++;
});

export default function ManufacturerDatabase(){
  const [search,setSearch]=useState("");
  const [countryFilter,setCountryFilter]=useState("All");
  const [statusFilter,setStatusFilter]=useState("All");
  const [sortCol,setSortCol]=useState("name");
  const [sortDir,setSortDir]=useState(1);
  const [expandedId,setExpandedId]=useState(null);

  const filtered=useMemo(()=>{
    let d=DATA;
    if(search){const s=search.toLowerCase();d=d.filter(m=>m.name.toLowerCase().includes(s));}
    if(countryFilter!=="All") d=d.filter(m=>m.country===countryFilter);
    if(statusFilter!=="All") d=d.filter(m=>m.status===statusFilter);
    return d.sort((a,b)=>{
      let va=a[sortCol],vb=b[sortCol];
      if(va==null&&vb==null)return 0;if(va==null)return 1;if(vb==null)return -1;
      if(typeof va==="string")return va.localeCompare(vb)*sortDir;
      return(va-vb)*sortDir;
    });
  },[search,countryFilter,statusFilter,sortCol,sortDir]);

  const handleSort=col=>{if(sortCol===col)setSortDir(d=>d*-1);else{setSortCol(col);setSortDir(1);}};
  const SortIcon=({col})=>{
    if(sortCol!==col)return <span style={{color:"#3d3d3d",marginLeft:3,fontSize:9}}>⇅</span>;
    return <span style={{color:"#f0a855",marginLeft:3,fontSize:9}}>{sortDir===1?"▲":"▼"}</span>;
  };
  const Null=()=><span style={{color:"#3a3a3a",fontStyle:"italic"}}>—</span>;
  const val=v=>v!=null?v:<Null/>;

  const COLS=[
    {key:"id",label:"#",w:40,align:"center"},
    {key:"name",label:"Manufacturer",w:200},
    {key:"country",label:"Country",w:120},
    {key:"founded",label:"Founded",w:80,align:"center"},
    {key:"status",label:"Status",w:100,align:"center"},
    {key:"specialty",label:"Specialty",w:280},
    {key:"pedal_count",label:"Pedals",w:64,align:"center"},
    {key:"website",label:"Website",w:160}
  ];

  const totalPedals = DATA.reduce((sum,m)=>sum+m.pedal_count,0);
  const activeCount = DATA.filter(m=>m.status==="Active").length;

  return(
    <div style={{fontFamily:"'SF Mono','Fira Code','Consolas',monospace",background:"#111",color:"#c8c8c8",minHeight:"100vh",padding:"24px 20px 40px"}}>
      {/* HEADER */}
      <div style={{display:"flex",alignItems:"flex-end",justifyContent:"space-between",marginBottom:18,flexWrap:"wrap",gap:8}}>
        <div>
          <div style={{display:"flex",alignItems:"baseline",gap:12,flexWrap:"wrap"}}>
            <h1 style={{margin:0,fontSize:24,fontWeight:700,color:"#f0f0f0",letterSpacing:"-0.5px",fontFamily:"'Helvetica Neue',sans-serif"}}>Manufacturer Database</h1>
            <span style={{fontSize:10,color:"#3d3d3d",fontFamily:"monospace"}}>{DATA.length} manufacturers · {activeCount} active · {totalPedals} pedals catalogued</span>
          </div>
        </div>
      </div>

      {/* FILTER BAR */}
      <div style={{display:"flex",gap:10,flexWrap:"wrap",marginBottom:16,alignItems:"center"}}>
        <div style={{position:"relative",flex:"1 1 220px",maxWidth:300}}>
          <span style={{position:"absolute",left:10,top:"50%",transform:"translateY(-50%)",color:"#3d3d3d",fontSize:13,pointerEvents:"none"}}>⌕</span>
          <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search manufacturer…" style={{
            width:"100%",boxSizing:"border-box",padding:"7px 12px 7px 28px",borderRadius:5,
            border:"1px solid #2a2a2a",background:"#161616",color:"#e0e0e0",fontSize:12,outline:"none",fontFamily:"monospace"
          }}/>
        </div>
        <select value={countryFilter} onChange={e=>setCountryFilter(e.target.value)} style={{
          padding:"7px 10px",borderRadius:5,border:"1px solid #2a2a2a",background:"#161616",
          color:"#a0a0a0",fontSize:12,outline:"none",fontFamily:"monospace",minWidth:140
        }}>
          {COUNTRIES.map(o=><option key={o} value={o}>{o==="All"?"Country: All":o}</option>)}
        </select>
        <select value={statusFilter} onChange={e=>setStatusFilter(e.target.value)} style={{
          padding:"7px 10px",borderRadius:5,border:"1px solid #2a2a2a",background:"#161616",
          color:"#a0a0a0",fontSize:12,outline:"none",fontFamily:"monospace",minWidth:140
        }}>
          {STATUSES.map(o=><option key={o} value={o}>{o==="All"?"Status: All":o}</option>)}
        </select>
        <span style={{marginLeft:"auto",fontSize:10,color:"#3d3d3d"}}>{filtered.length} manufacturer{filtered.length!==1?"s":""} shown</span>
      </div>

      {/* TABLE */}
      <div style={{overflowX:"auto",borderRadius:6,border:"1px solid #222",boxShadow:"0 4px 24px rgba(0,0,0,0.4)"}}>
        <table style={{borderCollapse:"collapse",width:"100%",minWidth:1050}}>
          <thead>
            <tr>
              {COLS.map(c=>(
                <th key={c.key} onClick={()=>handleSort(c.key)} style={{
                  padding:"9px 10px",background:"#151515",color:"#4a4a4a",fontSize:10,fontWeight:600,
                  textTransform:"uppercase",letterSpacing:"0.08em",whiteSpace:"nowrap",cursor:"pointer",
                  userSelect:"none",borderBottom:"1px solid #222",textAlign:c.align||"left",
                  width:c.w,position:"sticky",top:0,zIndex:2
                }}>{c.label}<SortIcon col={c.key}/></th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((m,i)=>{
              const isExp=expandedId===m.id;
              const ss=STATUS_STYLE[m.status]||STATUS_STYLE.Unknown;
              const rowBg=isExp?"#1c1c1c":(i%2===0?"#141414":"#181818");
              return[
                <tr key={m.id} onClick={()=>setExpandedId(isExp?null:m.id)}
                  style={{background:rowBg,cursor:"pointer",transition:"background 0.12s"}}
                  onMouseEnter={e=>{if(!isExp)e.currentTarget.style.background="#1e1e1e";}}
                  onMouseLeave={e=>{if(!isExp)e.currentTarget.style.background=rowBg;}}>
                  <td style={{padding:"7px 10px",textAlign:"center",color:"#3a3a3a",fontSize:10,borderBottom:"1px solid #1e1e1e"}}>{m.id}</td>
                  <td style={{padding:"7px 10px",color:"#f0f0f0",fontSize:12.5,fontWeight:600,borderBottom:"1px solid #1e1e1e",fontFamily:"'Helvetica Neue',sans-serif"}}>{m.name}</td>
                  <td style={{padding:"7px 10px",color:"#a0a0a0",fontSize:11,borderBottom:"1px solid #1e1e1e"}}>{val(m.country)}</td>
                  <td style={{padding:"7px 10px",textAlign:"center",color:"#6a6a6a",fontSize:11,borderBottom:"1px solid #1e1e1e"}}>{val(m.founded)}</td>
                  <td style={{padding:"7px 10px",textAlign:"center",borderBottom:"1px solid #1e1e1e"}}>
                    <span style={{display:"inline-block",padding:"3px 8px",borderRadius:3,fontSize:10.5,fontWeight:600,
                      background:ss.bg,color:ss.text,border:`1px solid ${ss.text}33`}}>{m.status}</span>
                  </td>
                  <td style={{padding:"7px 10px",color:"#6a6a6a",fontSize:11,borderBottom:"1px solid #1e1e1e"}}>{val(m.specialty)}</td>
                  <td style={{padding:"7px 10px",textAlign:"center",borderBottom:"1px solid #1e1e1e"}}>
                    {m.pedal_count>0
                      ?<span style={{color:"#f0a855",fontWeight:600,fontSize:12}}>{m.pedal_count}</span>
                      :<span style={{color:"#3a3a3a"}}>0</span>}
                  </td>
                  <td style={{padding:"7px 10px",borderBottom:"1px solid #1e1e1e"}}>
                    {m.website
                      ?<a href={m.website.startsWith("http")?m.website:`https://${m.website}`} target="_blank" rel="noopener noreferrer"
                        onClick={e=>e.stopPropagation()}
                        style={{color:"#5a9bcf",fontSize:11,textDecoration:"none"}}
                        onMouseEnter={e=>e.target.style.textDecoration="underline"}
                        onMouseLeave={e=>e.target.style.textDecoration="none"}>{m.website}</a>
                      :<Null/>}
                  </td>
                </tr>,
                isExp&&(
                  <tr key={`exp-${m.id}`}>
                    <td colSpan={8} style={{background:"#1a1a1a",borderBottom:"1px solid #2a2a2a",padding:"16px 18px 18px"}}>
                      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fill,minmax(200px,1fr))",gap:"12px 20px"}}>
                        <div>
                          <div style={{color:"#3d3d3d",fontSize:9,textTransform:"uppercase",letterSpacing:"0.1em",marginBottom:3}}>Notes</div>
                          <div style={{color:"#b0b0b0",fontSize:11.5}}>{m.notes??<Null/>}</div>
                        </div>
                        <div>
                          <div style={{color:"#3d3d3d",fontSize:9,textTransform:"uppercase",letterSpacing:"0.1em",marginBottom:3}}>Pedals in Database</div>
                          <div style={{color:m.pedal_count>0?"#f0a855":"#6a6a6a",fontSize:11.5,fontWeight:m.pedal_count>0?600:400}}>{m.pedal_count} pedal{m.pedal_count!==1?"s":""}</div>
                        </div>
                      </div>
                    </td>
                  </tr>
                )
              ];
            })}
          </tbody>
        </table>
        {filtered.length===0&&(
          <div style={{padding:48,textAlign:"center",color:"#3d3d3d",fontSize:13}}>No manufacturers match your filters.</div>
        )}
      </div>
    </div>
  );
}
