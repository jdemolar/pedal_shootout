import './app.scss';
import Nav from '../Nav';
import FeatureTable from '../FeatureTable';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import PedalSpecForm from '../PedalSpecForm';
import NotFound from '../NotFound';

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