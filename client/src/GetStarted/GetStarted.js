// cd client/ then run 'yarn add semantic-ui-react' and 'yarn add semantic-ui-css'

import React, { useState, useEffect } from 'react'
import './GetStarted.css'
import 'semantic-ui-css/semantic.min.css'
import { Button, Icon } from 'semantic-ui-react'
import { NavLink } from 'react-router-dom'


export function GetStarted() {
	const [picture, setPicture] = useState('')
	const [user, setUser] = useState('')

	useEffect(()=> {
		setPicture('https://i.pinimg.com/originals/b1/bb/ec/b1bbec499a0d66e5403480e8cda1bcbe.png')

		setUser({
			first_name: 'Amanda',
			last_name: 'Smith'
		})
	}, [])

	return(
		<div className="get-started">
			<header id="header">
				<h1>Pie for Providers</h1>
				<img src={picture} alt="text"/>
			</header>

			<div className="main-contianer">
				<h2>Setup</h2>

				<div className="second-container">

					<div className="third-container">
					
						<h2 id="welcome">Welcome to Pie for Providers, {user.first_name}!</h2>
						<h4>Get Started</h4>
						<p>Follow these instructions to set up your case daschboard. This should take about XX minutes, and you'll only have to do this once. Get ready to increase your slice of pie!</p>
					

						<h4>Steps</h4>
						<div className="step-container">
							<div className="steps">
								<Icon 
									style={{marginTop: "10px"}} 
									color="blue" 
									size="big" 
									name="briefcase"/>
								<h5>1. Add your business info</h5>

								<p>Tell us about the businesses and sites you manage, so we know which subsidy payment rates to apply to your cases.</p>
							</div>

							<div className="steps">
								<Icon 
									style={{marginTop: "10px"}} 
									color="blue" 
									size="big" 
									name="cloud upload"/>
								<h5>2. Upload your cases and review</h5>

								<p>Create and upload a spreadsheet with the names and birthays of the subsidy-elegible children you serve. In most cases, you can download this from other software you use. This help us calculate each child's subsidy payment rate.</p>
							</div>

							<div className="steps">
								<Icon 
									style={{marginTop: "10px"}} 
									color="blue" 
									size="big" 
									name="list" />
								<h5>3. Add some details</h5>

								<p>We'll need some more details about each subsidy case, like how many days the child was approved for. You can find most of this on the approval letter from the state. After you enter this, you'll only have to update once a year for most children.</p>
							</div>

							<div className="steps">
								<Icon 
									style={{marginTop: "10px"}} 
									color="blue" 
									size="big" 
									name="checkmark" />
								<h5>4. Done!</h5>

								<p>Start tracking your cases! Pie will help you manage your monthly billing cycle and all your annuals renewals. We're here to make it easy to get paid in full, for every child, every month.</p>
							</div>
						</div>

						<div id="button">
							<NavLink to={'/dashboard'}>
								<Button size="big" color="blue">GET STARTED</Button>
								
							</NavLink>
						</div>

					</div>

				</div>
			</div>
		</div>
		)
}