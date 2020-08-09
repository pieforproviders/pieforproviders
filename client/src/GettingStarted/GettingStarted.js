import React from 'react'
import { Button, Card, Typography } from 'antd'
import Icon from '@material-ui/core/Icon'
import AssignmentIcon from '@material-ui/icons/Assignment'
import BusinessIcon from '@material-ui/icons/Business'
import CloudUploadIcon from '@material-ui/icons/CloudUpload'
import PlaylistAddIcon from '@material-ui/icons/PlaylistAdd'

const cards = [
  {
    description: `
      Tell us about the businesses and sites you manage,
      so we know which subsidy payment rates to apply to your cases.
    `,
    icon: <BusinessIcon />,
    title: 'Add your business name'
  },
  {
    description: `
      Upload a spreadsheet with the names and birthdays of the subsidy-eligible children you serve.
      In most cases, you can download this from other software you use.
      This helps us calculate each child's subsidy payment rate.
    `,
    icon: <CloudUploadIcon />,
    title: 'Upload & review your cases'
  },
  {
    description: `
      We'll need some more details about each subsidy case,
      like how many days the child was approved for.
      You can find most of this on the approval letter from the state.
      After you enter this, you'll only have to update once a year for most children.
    `,
    icon: <PlaylistAddIcon />,
    title: 'Add your business info'
  },
  {
    description: `
      Let us know which agencies provide subsidies for which children,
      so we can keep track of your monthly billing cycles.
    `,
    icon: <AssignmentIcon />,
    title: 'Assign children to agencies'
  }
]

export function GettingStarted() {
  return (
    <div className="getting-started text-gray1">
      <div className="getting-started-content-area">
        <Typography.Title className="text-center">
          Welcome to Pie for Providers, Amanda!
        </Typography.Title>

        <div className="mb-8">
          <Typography.Title level={3}>Get Started</Typography.Title>
          <p>
            Follow these instructions to set up your case dashboard. This should
            take about 15 minutes, and you&apos;ll only have to do this once.
            Get ready to increase your slice of the pie!
          </p>
        </div>

        <Typography.Title level={3}>Steps</Typography.Title>
        <div className="grid grid-cols-1 medium:grid-cols-2 large:grid-cols-4 gap-4 mx-4">
          {cards.map((card, idx) => (
            <Card
              bordered={false}
              className="text-center text-gray1 mb-1"
              key={idx}
            >
              <Icon className="text-primaryBlue">{card.icon}</Icon>
              <p className="mt-4 mb-2 text-gray1 font-semibold">
                {idx + 1}. {card.title}
              </p>
              <p>{card.description}</p>
            </Card>
          ))}
        </div>

        <div className="mt-8 text-center">
          <Button
            type="primary"
            shape="round"
            size="large"
            className="uppercase"
          >
            Get started
          </Button>
        </div>
      </div>
    </div>
  )
}
