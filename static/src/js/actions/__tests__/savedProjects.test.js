import nock from 'nock'
import configureMockStore from 'redux-mock-store'
import thunk from 'redux-thunk'

import { SET_SAVED_PROJECTS } from '../../constants/actionTypes'
import { fetchSavedProjects, setSavedProjects } from '../savedProjects'

const mockStore = configureMockStore([thunk])

beforeEach(() => {
  jest.clearAllMocks()
  jest.restoreAllMocks()

  nock.disableNetConnect()
})

afterEach(() => {
  nock.cleanAll()
  nock.enableNetConnect()
})

describe('setSavedProjects', () => {
  test('should create an action to set the savedProjects', () => {
    const payload = {
      path: '/search',
      projectId: 1
    }

    const expectedAction = {
      type: SET_SAVED_PROJECTS,
      payload
    }

    expect(setSavedProjects(payload)).toEqual(expectedAction)
  })
})

describe('fetchSavedProjects', () => {
  test('updates the project name then calls updateSavedProject', async () => {
    const name = 'test name'

    nock(/localhost/)
      .get(/projects/)
      .reply(200, [{
        name,
        id: 1
      }])

    const store = mockStore({
      router: {
        location: {
          pathname: '/projectId=1',
          search: ''
        }
      },
      savedProject: {
        projectId: 1,
        path: '/search?p=C00001-EDSC'
      }
    })

    await store.dispatch(fetchSavedProjects(name)).then(() => {
      const storeActions = store.getActions()
      expect(storeActions[0]).toEqual({
        payload: [{
          name,
          id: 1
        }],
        type: SET_SAVED_PROJECTS
      })
    })
  })
})
