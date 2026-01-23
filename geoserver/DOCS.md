# Home Assistant GeoServer Add-on

## Installation

1. Add this repository to your Home Assistant Add-on Store.
2. Install the GeoServer add-on.
3. Configure the `username` and `password` in the Configuration tab.
4. Start the add-on.

## Usage

Once started, GeoServer should be accessible at:

`http://<your-home-assistant-ip>:8080/geoserver`

## Configuration

**Note**: The add-on attempts to set the `GEOSERVER_ADMIN_USER` and `GEOSERVER_ADMIN_PASSWORD` environment variables based on your configuration. If the underlying GeoServer version does not support these variables, the default credentials will be:

- Username: `admin`
- Password: `geoserver`

Please verify the logs if the password change does not take effect.

## Ports

The default port is 8080. You can map this to a different port in the Network section of the add-on configuration if desired.
