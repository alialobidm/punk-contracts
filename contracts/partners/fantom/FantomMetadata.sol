// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../../lib/strings.sol";

/// @title .fantom domain metadata contract
/// @author Tempe Techie
/// @notice Contract that stores metadata for the .fantom TLD
contract FantomMetadata is Ownable {
  string public description = "Fantom Names - Your web3 username and digital identity powered by the Punk Domains protocol. Mint yours now on FantomNames.org.";
  string public brand = "FantomNames.org";

  // EVENTS
  event DescriptionChanged(address indexed user, string description);
  event BrandChanged(address indexed user, string brand);

  // READ
  function getMetadata(string calldata _domainName, string calldata _tld, uint256 _tokenId) public view returns(string memory) {
    string memory fullDomainName = string(abi.encodePacked(_domainName, _tld));
    uint256 domainLength = strings.len(strings.toSlice(_domainName));

    return string(
      abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(abi.encodePacked(
        '{"name": "', fullDomainName, '", ',
        '"description": "', description, '", ',
        '"attributes": [',
          '{"trait_type": "length", "value": "', Strings.toString(domainLength) ,'"}'
        '], '
        '"image": "', _getImage(fullDomainName), '"}'))))
    );
  }

  function _getImage(string memory _fullDomainName) internal view returns (string memory) {
    string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="500" height="500">',
        '<rect x="0" y="0" width="500" height="500" fill="#1969FF"/>',
        '<path transform="scale(0.20 0.20) translate(750)" d="M480.952632,162.820404 C498.202214,153.726532 524.449007,153.726532 541.698589,162.820404 L717.715301,255.615438 C728.104233,261.091936 733.809736,269.25319 734.831811,277.678216 L735,277.678216 L735,744.110155 C734.770819,753.300673 729.011717,762.429399 717.715301,768.384559 L541.698589,861.179741 C524.449007,870.27342 498.202214,870.27342 480.952632,861.179741 L304.936382,768.384559 C293.687466,762.4543 288.288954,753.261937 288.021607,744.110155 C287.994161,743.171274 287.991758,742.397481 288.020775,741.760186 L288.021607,280.818578 C287.995362,280.170216 287.995085,279.52462 288.02096,278.881791 L288.021607,277.678216 L288.100249,277.678216 C288.882053,269.16004 294.328618,261.207221 304.936382,255.615438 L480.952632,162.820404 Z M707,537 L541.644818,624.459967 C524.420262,633.571112 498.21155,633.571112 480.986994,624.459967 L316,537.194955 L316,742.669239 L480.986994,829.471349 C490.737056,834.688013 500.874684,839.770703 510.746553,839.992453 L511.315906,840 C521.168396,840.032183 530.733903,835.022485 540.433212,830.279812 L707,741.920834 L707,537 Z M260.423841,734 C260.423841,751.880605 262.483542,763.633063 266.573125,771.912197 C269.962755,778.774873 275.048664,784.019001 284.335203,790.400911 L284.865291,790.762639 C286.903313,792.149569 289.148339,793.602016 291.881192,795.308227 L295.103883,797.299574 L305,803.325293 L290.80629,827 L279.729986,820.250826 L277.868233,819.097358 C274.665666,817.102319 272.011205,815.389649 269.535301,813.704662 C243.068452,795.702251 233.197716,776.074834 233.002947,735.2439 L233,734 L260.423841,734 Z M498,413 C496.719282,413.440417 495.51884,413.951152 494.424509,414.530355 L318.676529,507.623888 C318.49208,507.721039 318.316212,507.818189 318.148833,507.91349 L318,507.999537 L318.275982,508.15868 L318.676529,508.376112 L494.424509,601.469645 C495.51884,602.048848 496.719282,602.559583 498,603 L498,413 Z M526,413 L526,603 C527.281635,602.559583 528.482071,602.048848 529.576397,601.469645 L705.322736,508.376112 C705.507277,508.278961 705.683513,508.181811 705.850522,508.08651 L706,507.999537 L705.724112,507.84132 L705.322736,507.623888 L529.576397,414.530355 C528.482071,413.951152 527.281635,413.440417 526,413 Z M707,311 L549,394 L707,477 L707,311 Z M316,311 L316,477 L474,394 L316,311 Z M529.422488,187.627114 C520.27514,182.790962 503.724952,182.790962 494.577605,187.627114 L318.677116,280.623711 C318.492507,280.721685 318.316486,280.817811 318.148962,280.913937 L318,280.999896 L318.276221,281.157949 L318.677116,281.376081 L494.577605,374.3724 C503.724952,379.2092 520.27514,379.2092 529.422488,374.3724 L705.322145,281.376081 C705.506847,281.278107 705.683237,281.181981 705.850392,281.086779 L706,280.999896 L705.723871,280.841843 L705.322145,280.623711 L529.422488,187.627114 Z M733.193821,197 L744.270251,203.749273 L746.131721,204.902466 C749.33418,206.896953 751.988718,208.610547 754.464885,210.294705 C780.931599,228.297503 790.802419,247.925124 790.997256,288.756099 L791,290 L763.576481,290 C763.576481,272.118455 761.516516,260.366907 757.426771,252.086842 C754.037707,245.224806 748.951824,239.980488 739.665515,233.599218 L739.134973,233.236751 C737.096961,231.850558 734.852221,230.398109 732.119016,228.691528 L728.896433,226.700086 L719,220.674731 L733.193821,197 Z" fill="#FFFFFF" fill-rule="nonzero"></path>',
        '<text x="50%" y="50%" dominant-baseline="middle" fill="white" text-anchor="middle" font-size="x-large" font-family="sans-serif">',
        _fullDomainName,'</text>',
        '<text x="50%" y="70%" dominant-baseline="middle" fill="white" text-anchor="middle" font-family="sans-serif">',
        brand,'</text>',
      '</svg>'
    ))));

    return string(abi.encodePacked("data:image/svg+xml;base64,", svgBase64Encoded));
  }

  // WRITE (OWNER)

  /// @notice Only metadata contract owner can call this function.
  function changeDescription(string calldata _description) external onlyOwner {
    description = _description;
    emit DescriptionChanged(msg.sender, _description);
  }

  /// @notice Only metadata contract owner can call this function.
  function changeBrand(string calldata _brand) external onlyOwner {
    brand = _brand;
    emit BrandChanged(msg.sender, _brand);
  }
}