import './index.scss';

interface Props {
	clnm: string;
	tooltipContent: string;
	cellContent: string;
}

const DetailsTooltip = ({clnm, tooltipContent, cellContent}: Props) => {
	clnm = clnm + ' details-tooltip'

	return (
		<td className={clnm} data-title={tooltipContent}>
			{cellContent}
		</td>
	)
}

export default DetailsTooltip;