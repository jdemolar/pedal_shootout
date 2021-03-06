import './app.scss';
import * as Realm from 'realm-web';
import { useState, useEffect } from "react";
import Loading from '../Loading';
import FeatureTable from '../FeatureTable';
import FeatureRow from '../FeatureRow';

const App = () => {
	
	const [pedals, setPedals] = useState([]);
	const [loading, setLoading] = useState(true);

	useEffect(() => {
		async function getPedalsData () {
			const realmApp = new Realm.App({id: "pedal_shootout-kycqe"});
			const creds = Realm.Credentials.anonymous();

			try {
				const user = await realmApp.logIn(creds);
				const pedalsArray = await user.functions.listAllPedals();
				setPedals(pedalsArray);
				// setTimeout(function() {
				// 	console.log(pedalsArray);
				// }, 5000);
			} catch (err) {

			}

			setLoading(false);
		}

		if (loading) {
			getPedalsData();
		}
	}, [loading])


	return (
		<div className="app">
			{loading && (
				<div className="text-center">
					<Loading />
				</div>
			)}
			<FeatureTable>
				{
					pedals.map((pedal) => {
						console.log(pedal);
						return <FeatureRow
							key={pedal['pedalId']}
							pedalManufacturer={pedal['pedalManufacturer']}
							pedalName={pedal['pedalName']}
							effectTypes={pedal['effectTypes']}
							audioSignalType={pedal['audioSignalType']}
							trueBypass={pedal['isTrueBypassAudioSignal']}
							audioMix={pedal['audioMix']}
							hasReorderableLoops={pedal['hasReorderableLoops']}
							numberOfPresets={pedal['numberOfPresets']}
							software={pedal['software']}
							audioConnections={pedal['audioConnections']}
							powerConnections={pedal['powerConnections']}
							midiFeatures={pedal['midiFeatures']}
							auxiliaryJacks={pedal['auxiliaryJacks']}
						/>
					})
				}
			</FeatureTable>
		</div>
	);
};

export default App;