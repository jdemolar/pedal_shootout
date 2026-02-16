import './app.scss';
import Nav from '../Nav';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import NotFound from '../NotFound';
import Manufacturers from '../Manufacturers';
import Pedals from '../Pedals';
import MidiControllers from '../MidiControllers';
import Pedalboards from '../Pedalboards';
import PowerSupplies from '../PowerSupplies';
import Utilities from '../Utilities';
import Workbench from '../Workbench';
import { WorkbenchProvider } from '../../context/WorkbenchContext';

const App = () => {

	const navElements = [
		{label: 'Manufacturers',		link: 'manufacturers',		component: <Manufacturers />},
		{label: 'Pedals',				link: 'pedals',				component: <Pedals />},
		{label: 'MIDI Controllers',		link: 'midi-controllers',	component: <MidiControllers />},
		{label: 'Pedalboards',			link: 'pedalboards',		component: <Pedalboards />},
		{label: 'Power Supplies',		link: 'power-supplies',		component: <PowerSupplies />},
		{label: 'Utilities',			link: 'utilities',			component: <Utilities />},
	];

	return (
		<Router>
			<WorkbenchProvider>
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
						<Route path='/workbench' element={<Workbench />} />
						<Route path='*' element={<NotFound />} />
					</Routes>
				</div>
			</WorkbenchProvider>
		</Router>
	);
};

export default App;
