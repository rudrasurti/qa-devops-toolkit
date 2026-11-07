*** Settings ***
Documentation     API tests that run against a WireMock mock of the booking API.
...               The mock makes tests fast, stable and runnable offline.
Library           RequestsLibrary
Library           Collections
Suite Setup       Start Session And Wait For Mock

*** Variables ***
${BASE_URL}       %{BASE_URL=http://localhost:8080}
&{BOOKING}        firstname=Rudra    lastname=Surti    totalprice=${150}    depositpaid=${True}

*** Test Cases ***
Health Check Returns 201
    [Tags]    smoke
    GET On Session    api    /ping    expected_status=201

Valid Login Returns A Token
    [Tags]    smoke    auth
    ${token}=    Get Token
    Should Be Equal    ${token}    abc123

Invalid Login Is Rejected
    [Tags]    negative    auth
    ${body}=    Create Dictionary    username=admin    password=wrong
    ${resp}=    POST On Session    api    /auth    json=${body}
    Dictionary Should Contain Item    ${resp.json()}    reason    Bad credentials

Create Booking Echoes The Request
    [Tags]    smoke
    ${resp}=    POST On Session    api    /booking    json=${BOOKING}
    Should Be Equal As Integers    ${resp.json()}[bookingid]    1
    Should Be Equal    ${resp.json()}[booking][firstname]    Rudra
    Should Be Equal As Integers    ${resp.json()}[booking][totalprice]    150

Get Booking Returns The Stored Data
    ${resp}=    GET On Session    api    /booking/1
    Should Be Equal    ${resp.json()}[lastname]    Surti

Unknown Booking Returns 404
    [Tags]    negative
    GET On Session    api    /booking/999    expected_status=404

Delete Without Token Returns 403
    [Tags]    negative    security
    DELETE On Session    api    /booking/1    expected_status=403

Delete With Token Returns 201
    [Tags]    security
    ${token}=    Get Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    DELETE On Session    api    /booking/1    headers=${headers}    expected_status=201

Slow Dependency Responds Within Two Seconds
    [Tags]    performance
    ${resp}=    GET On Session    api    /booking/slow
    Should Be True    ${resp.elapsed.total_seconds()} < 2

*** Keywords ***
Start Session And Wait For Mock
    Create Session    api    ${BASE_URL}
    Wait Until Keyword Succeeds    30x    1s    GET On Session    api    /ping    expected_status=201

Get Token
    ${body}=    Create Dictionary    username=admin    password=password123
    ${resp}=    POST On Session    api    /auth    json=${body}
    RETURN    ${resp.json()}[token]
