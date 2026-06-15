
package seeya.insight.user.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User {
  private String userId;
  private String password;
  private String nickname;
  private String email;
  private int winCount;
  private int loseCount;
  private int drawCount;
  private String userIcon;
  private String fileNm;

}
