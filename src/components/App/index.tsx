import './app.scss';
import Nav from '../Nav';
import FeatureTable from '../FeatureTable';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import PedalSpecForm from '../PedalSpecForm';

const App = () => {
	
	const navElements = [
		{label: 'Features Table',		link: 'feature-table',	component: <FeatureTable />},
		{label: 'Submit Pedal Data',	link: 'pedal-form',		component: <PedalSpecForm />},
	];

	return (
		<Router>
			<div className="app">
				<Nav
					key='navElements'
					elements={navElements}
				/>
				<Routes>
					{navElements.map((navElement) => {
						return <Route path={'/' + navElement.link} element={navElement.component}/>
					})}
				</Routes>
			</div>
		</Router>
	);
};

export default App;