import './app.scss';
import Nav from '../Nav';
import FeatureTable from '../FeatureTable';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import PedalSpecForm from '../PedalSpecForm';
import NotFound from '../NotFound';
// TODO: Migrate PedalDatabase component from raw_data to apps/web/src/components
// import PedalDatabase from '../../../raw_data/pedal_database_view';
import Manufacturers from '../Manufacturers';
import Pedals from '../Pedals';
import MidiControllers from '../MidiControllers';
import Pedalboards from '../Pedalboards';
import PowerSupplies from '../PowerSupplies';
import Utilities from '../Utilities';

const App = () => {

	const navElements = [
		{label: 'Features Table',		link: 'feature-table',		component: <FeatureTable />},
		{label: 'Submit Pedal Data',	link: 'pedal-form',			component: <PedalSpecForm />},
		// {label: 'Pedal Database',	link: 'pedal-database',		component: <PedalDatabase />},  // TODO: Migrate from raw_data
		{label: 'Manufacturers',		link: 'manufacturers',		component: <Manufacturers />},
		{label: 'Pedals',				link: 'pedals',				component: <Pedals />},
		{label: 'MIDI Controllers',		link: 'midi-controllers',	component: <MidiControllers />},
		{label: 'Pedalboards',			link: 'pedalboards',		component: <Pedalboards />},
		{label: 'Power Supplies',		link: 'power-supplies',		component: <PowerSupplies />},
		{label: 'Utilities',			link: 'utilities',			component: <Utilities />},
	];

	return (
		<Router>
			<div className="app">
				<Nav
					key='navElements'
					elements={navElements}
				/>
				<Routes>
					<Route path='/' element={<Navigate to={navElements[0].link} replace />} />
					{navElements.map((navElement) => {
						return <Route key={navElement.link} path={'/' + navElement.link} element={navElement.component}/>
					})}
					<Route path='*' element={<NotFound />} />
				</Routes>
			</div>
		</Router>
	);
};

export default App;